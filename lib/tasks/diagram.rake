# Tasks for generating diagrams with Railroady.

module AaltoApps
  module RakeHelpers
    DIAGRAM_FORMATS = ENV['FORMATS'].andand.split(/[,;:\s]\s*/) || %w[svg png]

    def self.with_graphviz_command_pipes(outfile_base)
      commands = DIAGRAM_FORMATS.map {|fmt|
        fmt = fmt.shellescape
        "sfdp -T#{fmt}" +
          " -GK=2" +  # ideal edge length
          " -Nfontsize=10 -Efontsize=10" +
          " -o#{outfile_base.shellescape}.#{fmt}"
      }

      pipes = []
      begin
        commands.each {|cmd| pipes << open("|#{cmd}", 'w') }
        yield pipes
      ensure
        pipes.each {|io| io.close }
      end
    end
  end
end

namespace :custom_diagram do

  desc 'Generates a class diagram for models.'
  task :models do
    AaltoApps::RakeHelpers.with_graphviz_command_pipes('doc/models') do |pipes|
      IO.foreach "|railroady -iamM" do |line|
        # filter out ActsAsTaggableOn vertices and edges except for the edge tags
        # and the vertex it points to
        unless line =~ /"Product"\s*->\s*"ActsAsTaggableOn::Tag(ging)?"\s*\[.*\blabel=(?!"tags")/
          pipes.each {|io| io << line }
        end
      end
    end
  end

  desc 'Generates a class diagram for controllers.'
  task :controllers do
    AaltoApps::RakeHelpers.with_graphviz_command_pipes('doc/controllers') do |pipes|
      IO.foreach "|railroady -iC" do |line|
        # filter out methods that start with "_"
        line.gsub!(/\[.*\]/) do |attrs|
          attrs.sub(/(?<=\Wlabel="\{).*?(?=\}")/) do |label|
            label.gsub(/(?<=\||\\l)_.*?(\\l|\z)/, '')
          end
        end
        pipes.each {|io| io << line }
      end
    end
  end

  task :all => [:controllers, :models]
end

task :custom_diagram => ['custom_diagram:all']
