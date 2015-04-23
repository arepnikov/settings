module Canonize
  def self.data_source(path)
    Settings::DataSource::File.build(path)
  end

  def self.current_dir
    File.dirname(File.expand_path(__FILE__))
  end

  def self.default_filename
    'settings.json'
  end

  def self.current_dir_filepath
    File.join(current_dir, "settings.json")
  end

  def self.working_dir_filepath(filepath=nil)
    filepath ||= default_filename
    File.join(Dir.pwd, filepath)
  end
end

describe "Default Filepath", :* do
  specify "The default settings filename (settings.json) is used when the source is a directory" do
    data_source = Canonize.data_source(Canonize.current_dir)

    pathname = data_source.canonical

    assert(pathname == Canonize.current_dir_filepath)
  end

  specify "The current working directory is used when the source is a filename" do
    data_source = Canonize.data_source('some_file.json')

    pathname = data_source.canonical

    assert(pathname == Canonize.working_dir_filepath('some_file.json'))
  end
end

describe Settings, "Default Pathname", :* do
  specify "The current working directory and the default filename are used when the path is not specified" do
    data_source = Canonize.data_source(nil)

    pathname = data_source.canonical

    assert(pathname == Canonize.working_dir_filepath)
  end
end
