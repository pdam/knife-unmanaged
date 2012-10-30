require 'chef_fs/knife'
require 'chef_fs/command_line'

class Chef
  class Knife
    class Download < ChefFS::Knife
      banner "knife install  PATTERNS"

      common_options


      option :run_list,
        :long => '--run_list',
        :boolean => true,
        :default => true,
        :description => " Runlist  pattern "

      option :purge,
        :long => '--[no-]purge',
        :boolean => true,
        :default => false,
        :description => "Delete matching local files and directories that do not exist remotely."

      option :force,
        :long => '--[no-]force',
        :boolean => true,
        :default => false,
        :description => "Force upload of files even if they match (quicker and harmless, but doesn't print out what it changed)"

      option :dry_run,
        :long => '--dry-run',
        :short => '-n',
        :boolean => true,
        :default => false,
        :description => "Don't take action, only print what would happen"

      def run
	@node_name = 'pdam-ubuntu' # 'ephemeral'+ Time.now.to_i.to_s
        @run_list  = pattern_args_from(name_args.length > 0 ? name_args : [ "" ])
	@node = Chef::Node.new(@node_name)
        @node.run_list = @run_list 
	@node.save
	IO.popen(" knife exec -E (api.get '/nodes/#{@node_name}/cookbooks').each { |cb| pp cb[0] => cb[1].version } " )  { 
	  |io| while (line = io.gets) do
		puts line
	end  
	}
	@cookbooklist= "#{line}".split /,/
        # Get the matches (recursively)
        @cookbooklist.each do |cookbook|
          ChefFS::FileSystem.copy_to(cookbook , chef_fs, local_fs, config[:recurse] ? nil : 1, config)
        end
      end
    end
  end
end

