require "logger"
require "fileutils"
require "meshx-plugin-sdk"
require 'fileutils'

class Plugin
  def initialize(api, log, config)
    @api = api
    @log = log
    @config = config
    @plugin_id = Helper.get_env_or_fail("X_PLUGIN_ID")   
  end

  def on_init()
    begin
      @log.info("on_init")
      @log.info(`wget https://github.com/suntong/html2md/releases/download/v1.5.0/html2md_1.5.0_linux_amd64.tar.gz`)
      @log.info(`tar -zxvf ./html2md_1.5.0_linux_amd64.tar.gz`)
      @log.info(`mv html2md_1.5.0_linux_amd64/html2md /home/user/html2md`)
    rescue => e
      @log.error("execption on_init: #{e}")
    end
  end

  def on_start()
    @log.info("on_start")  

    begin
      tmp_path = File.join(@config.get("tmp_path"),"site")
      storage_path = @config.get("storage_path")
      data_object_name = @config.get("data_object_name")


      @log.info("tmp_path: #{tmp_path}")
      @log.info("storage_path: #{storage_path}")  

      FileUtils.mkdir_p storage_path
      FileUtils.mkdir_p tmp_path

      Dir.chdir(tmp_path){
        @log.info("pull #{data_object_name}")
        cli = "oras pull #{data_object_name} "
        @log.info("cli: #{cli}")
        @log.info(`#{cli}`)
        folders = Dir["./"]
        puts(folders)
        folders.each do |folder|
          @log.info("folder: " + folder)
          html2md = Html2MD.new(@log,@api,folder,storage_path)
          html2md.process()
        end
     }

    rescue => e
      @log.error("exception on_start: #{e}")
    end

    @log.info("exit")
    @api.exit()
    
  end

  def on_file_event(event)
    @log.info("on_file_event #{event.path} #{event.filename}")
  end

  def on_complete_event(event)
    @log.info("on_complete_event")
  end

  def on_folder_event(event)
    @log.info("on_folder_event")
  end

  def on_end()
    @log.info("on_end")
  end

end

class Html2MD
    def initialize(log,api,folder,tmp_path)
      @log = log
      @api = api    
      @folder = folder
      @tmp_path = tmp_path
    end

    def process_file(file)
        @log.info("process_file: #{file}")        
        file_content = `/home/user/html2md -i #{file} `
        output_path = File.join(@tmp_path,file.gsub(@folder,"")).gsub(".html",".md").gsub(".htm",".md")
        @log.info("output path :" + output_path)
        dirs = File.dirname(output_path)
        FileUtils.mkdir_p(dirs) unless File.directory?(dirs)
        File.write(output_path,file_content)

        #write the file to cache
        result = @api.file_cache_write(output_path)
        if result.exit_code != 0
          log.error("failed to write file to cache: #{result.error} #{result.exit_code}")         
        else
          # send file event 
          log.info(" writen to cache dest: #{result.destination} sending file event")
          res1 = api.send_file_event(result.destination, File.basename(output_path), output_path, "website")
          if res1.exit_code != 0
            log.error("failed to send file event: #{res1.error} #{res1.exit_code}")
          end
        end
    end

    def process()
        @log.info("process html")
        records = Dir.glob("#{@folder}/**/*.html").map do |file|
            process_file(file)
        end
        @log.info("process htm")
        records = Dir.glob("#{@folder}/**/*.htm").map do |file|
            process_file(file)
        end
    end
end



