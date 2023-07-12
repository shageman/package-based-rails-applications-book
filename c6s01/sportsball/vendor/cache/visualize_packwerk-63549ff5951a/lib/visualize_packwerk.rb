# typed: strict

require 'erb'
require 'packs'
require 'parse_packwerk'

module VisualizePackwerk

  def self.package_graph!(options)
    config = ParsePackwerk::Configuration.fetch
    
    all_packages = filtered(Packs.all, options.only_package) 
    all_package_names = all_packages.map &:name

    architecture_layers = (config.raw['architecture_layers'] || []) + ["NotInLayer"]
    grouped_packages = architecture_layers.inject({}) do |result, key|
      result[key] = []
      result
    end

    all_packages.each do |package|
      grouped_packages[package.config['layer'] || "NotInLayer"] << package
    end

    file = File.open(File.expand_path File.dirname(__FILE__) + "/graph.dot.erb")
    templ = file.read.gsub(/^ *(<%.+%>) *$/, '\1')
    template = ERB.new(templ, trim_mode: "%<>")
    puts template.result(binding)
  end

  private 

  def self.filtered(all_packages, filter_package)
    packages = all_packages.map { |pack| ParsePackwerk.find(pack.name) }
    return packages unless filter_package

    result = [filter_package]
    result += packages.select{ |p| p.dependencies.include? filter_package }.map { |pack| pack.name }
    result += ParsePackwerk.find(filter_package).dependencies
    result += packages.select{ |p| p.violations.map(&:to_package_name).include? filter_package }.map { |pack| pack.name }
    result += ParsePackwerk.find(filter_package).violations.map(&:to_package_name)
    result = result.uniq

    result.map { |pack_name| ParsePackwerk.find(pack_name) }
  end
end
