# typed: strict

require 'erb'
require 'packs'
require 'parse_packwerk'
require 'digest/md5'

module VisualizePackwerk

  def self.package_graph!(options, raw_config, packwerk_packages)
    raise ArgumentError, "Package #{options.show_only_focus_package} does not exist" if options.show_only_focus_package && !packwerk_packages.map(&:name).include?(options.show_only_focus_package)

    all_packages = filtered(packwerk_packages, options.show_only_focus_package)
    all_package_names = all_packages.map &:name

    show_edge = show_edge_builder(options, all_package_names)
    node_color = node_color_builder()
    max_violation_count = max_violation_count(all_packages, show_edge)

    title = diagram_title(options, max_violation_count)

    architecture_layers = (raw_config['architecture_layers'] || []) + ["NotInLayer"]
    grouped_packages = architecture_layers.inject({}) do |result, key|
      result[key] = []
      result
    end

    all_packages.each do |package|
      key = package.config['layer'] || "NotInLayer"
      if architecture_layers.include?(key)
        grouped_packages[key] << package
      else
        raise RuntimeError, "Package #{package.name} has architecture layer key #{key}. Known layers are only #{architecture_layers.join(", ")}"
      end
    end

    all_team_names = all_packages.map { |p| code_owner(p) }.uniq

    file = File.open(File.expand_path File.dirname(__FILE__) + "/graph.dot.erb")
    templ = file.read.gsub(/^ *(<%.+%>) *$/, '\1')
    template = ERB.new(templ, trim_mode: "<>-")
    template.result(binding)
  end

  private 

  def self.code_owner(package)
    package.config.dig("metadata", "owner") || package.config["owner"]
  end

  def self.diagram_title(options, max_violation_count)
    app_name = File.basename(Dir.pwd)
    focus_edge_info = options.show_only_focus_package && options.show_only_edges_to_focus_package ? "showing only edges to/from focus pack" : "showing all edges between visible packs"
    focus_info = options.show_only_focus_package ? "Focus on #{options.show_only_focus_package} (#{focus_edge_info})" : "All packs"
    skipped_info = 
    [
      options.show_layers ? nil : "hiding layers",
      options.show_dependencies ? nil : "hiding dependencies",
      options.show_todos ? nil : "hiding todos",
      options.show_privacy ? nil : "hiding privacy",
      options.show_teams ? nil : "hiding teams",
    ].compact.join(', ').strip
    main_title = "#{app_name}: #{focus_info}#{skipped_info != '' ? ' - ' + skipped_info : ''}"
    sub_title = ""
    if options.show_todos && max_violation_count
      sub_title = "<br/><font point-size='12'>Widest todo edge is #{max_violation_count} violation#{max_violation_count > 1 ? 's' : ''}</font>"
    end
    "<<b>#{main_title}</b>#{sub_title}>"
  end

  def self.show_edge_builder(options, all_package_names)
    return lambda do |start_node, end_node|
      (
        !options.show_only_edges_to_focus_package && 
        all_package_names.include?(start_node) && 
        all_package_names.include?(end_node)
      ) ||
      (
        options.show_only_edges_to_focus_package && 
        all_package_names.include?(start_node) && 
        all_package_names.include?(end_node) && 
        [start_node, end_node].include?(options.show_only_focus_package)
      )
    end
  end

  def self.node_color_builder
    return lambda do |text|
      return unless text
      hash_value = Digest::SHA256.hexdigest(text.encode('utf-8'))
      color_code = hash_value[0, 6]
      r = color_code[0, 2].to_i(16) % 128 + 128
      g = color_code[2, 2].to_i(16) % 128 + 128
      b = color_code[4, 2].to_i(16) % 128 + 128
      hex = "#%02X%02X%02X" % [r, g, b]
    end
  end

  def self.max_violation_count(all_packages, show_edge)
    violation_counts = {}
    all_packages.each do |package|
      violations_by_package = package.violations.group_by(&:to_package_name)
      violations_by_package.keys.each do |violations_to_package|
        violation_types = violations_by_package[violations_to_package].group_by(&:type)
        violation_types.keys.each do |violation_type|
          if show_edge.call(package.name, violations_to_package)
            key = "#{package.name}->#{violations_to_package}:#{violation_type}"
            violation_counts[key] = violation_types[violation_type].count
            # violation_counts[key] += 1
          end
        end
      end
    end
    violation_counts.values.max
  end

  def self.filtered(packwerk_packages, filter_package)
    return packwerk_packages unless filter_package

    result = [filter_package]
    result += packwerk_packages.select{ |p| p.dependencies.include? filter_package }.map { |pack| pack.name }
    result += ParsePackwerk.find(filter_package).dependencies
    result += packwerk_packages.select{ |p| p.violations.map(&:to_package_name).include? filter_package }.map { |pack| pack.name }
    result += ParsePackwerk.find(filter_package).violations.map(&:to_package_name)
    result = result.uniq

    result.map { |pack_name| ParsePackwerk.find(pack_name) }
  end
end
