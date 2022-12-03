# frozen_string_literal: true

require 'pathname'
require 'yaml'
require 'ruby-graphviz'

module Pocky
  class InvalidRootPathError < StandardError
  end

  class Packwerk
    DEPENDENCIES_FILENAME = 'package.yml'
    DEPRECATED_REFERENCES_FILENAME = 'deprecated_references.yml'
    MAX_EDGE_WIDTH = 5

    def self.generate(params)
      new(**params).generate
    end

    private_class_method :new
    def initialize(
      package_path: nil,
      default_package: '',
      filename: 'packwerk.png',
      dpi: 100,
      package_color: '#5CC8FF',
      dependency_edge: 'darkgreen',
      deprecated_reference_edge: 'black'
    )
      @package_paths = [*package_path] if package_path
      @root_path = defined?(Rails) ? Rails.root : Pathname.new(Dir.pwd)

      @default_package = default_package
      @filename = filename
      @dpi = dpi.to_i
      @deprecated_references = {}
      @package_dependencies = {}
      @nodes = {}

      @node_options = {
        fontsize: 26.0,
        fontcolor: 'white',
        fillcolor: package_color,
        color: package_color,
        height: 1.0,
        style: 'filled, rounded',
        shape: 'box',
      }

      @deprecated_references_edge_options = {
        color: deprecated_reference_edge,
      }

      @dependency_edge_options = {
        color: dependency_edge
      }
    end

    def generate
      load_dependencies
      load_deprecated_references
      build_directed_graph
    end

    private

    def build_directed_graph
      @graph = GraphViz.new(:G, type: :digraph, dpi: @dpi)
      draw_dependencies
      draw_deprecated_references
      @graph.output(png: @filename)
    end

    def draw_dependencies
      @package_dependencies.each do |package, file|
        @nodes[package] ||= create_node(package)
        file.each do |provider|
          provider_package = package_name_for_dependency(provider)
          @nodes[provider_package] ||= create_node(provider_package)

          @graph.add_edges(
            @nodes[package],
            @nodes[provider_package],
            **@dependency_edge_options
          )
        end
      end
    end

    def draw_deprecated_references
      @deprecated_references.each do |package, references|
        @nodes[package] ||= create_node(package)
        references.each do |provider, invocations|
          provider_package = package_name_for_dependency(provider)
          @nodes[provider_package] ||= create_node(provider_package)

          @graph.add_edges(
            @nodes[package],
            @nodes[provider_package],
            **@deprecated_references_edge_options.merge(penwidth: edge_width(invocations.length)),
          )
        end
      end
    end

    def edge_width(count)
      [
        [(count / 5).to_i, 1].max,
        MAX_EDGE_WIDTH
      ].min
    end

    def deprecated_references_files
      @deprecated_references_files ||= begin
        return Dir[@root_path.join('**', DEPRECATED_REFERENCES_FILENAME).to_s] unless @package_paths

        @package_paths.flat_map do |path|
          Dir[@root_path.join(path, '**', DEPRECATED_REFERENCES_FILENAME).to_s]
        end
      end
    end

    def dependencies_files
      @dependencies_files ||= begin
        return Dir[@root_path.join('**', DEPENDENCIES_FILENAME).to_s] unless @package_paths

        @package_paths.flat_map do |path|
          Dir[@root_path.join(path, '**', DEPENDENCIES_FILENAME).to_s]
        end
      end
    end

    def load_dependencies
      return if dependencies_files.empty?

      dependencies_files.each do |filename|
        package = parse_package_name(filename)
        @package_dependencies[package] ||= begin
          yml = YAML.load_file(filename) || {}
          yml['dependencies'] || []
        end
      end
    end

    def load_deprecated_references
      return if deprecated_references_files.empty?

      deprecated_references_files.each do |filename|
        package = parse_package_name(filename)
        @deprecated_references[package] ||= YAML.load_file(filename) || {}
      end
    end

    def parse_package_name(filename)
      name = File.dirname(filename).gsub(@root_path.to_s, '')
      name == '' ? @default_package : name.gsub(/^\//, '')
    end

    def package_name_for_dependency(name)
      name == '.' ? @default_package : name
    end

    def create_node(package)
      @graph.add_nodes(package, **@node_options.merge({label: package}))
    end
  end
end
