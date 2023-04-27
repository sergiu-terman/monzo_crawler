module Aux
  class FileManager

    def write(name, content)
      tarfile = StringIO.new
      tarwriter = Gem::Package::TarWriter.new(tarfile)

      tarwriter.add_file("#{name}.html", 0644) do |f|
        f.write(content)
      end

      tarwriter.close
      tarfile.rewind

      gzipfile = Zlib::GzipWriter.new(File.open(file_path(name), 'wb'))
      gzipfile.write(tarfile.read)
      gzipfile.close
    end

    def read(name)
      tar_gz = Zlib::GzipReader.open(file_path(name))
      tar = Gem::Package::TarReader.new(tar_gz)

      content = tar.first.read

      # cleanup
      tar.close
      tar_gz.close

      return content
    end

    def file_path(name)
      File.join(dir_path, "#{name}.gz")
    end

    def dir_path
      Pathname.new("#{ENV['WORKDIR']}/storage/web/")
    end
  end
end
