NON_CONFIG_FILES = %w[init LICENSE prefs Rakefile README.md]
ROOT_DIR = File.dirname(__FILE__)
FISH_CONFIG_PATH = File.join(ROOT_DIR, 'sh', 'fish')
INSTALL_PATH = '~'
FISH_INSTALL_PATH = File.join(INSTALL_PATH, '.config', 'fish')

desc 'link dotfiles into ~'
task :install do
  @replace_all = false
  process_files(config_files, &method(:install_file))
  process_files(config_files(true), FISH_CONFIG_PATH, FISH_INSTALL_PATH, false, &method(:install_file))
end

desc 'unlink dotfiles from ~'
task :uninstall do
  @remove_all = false
  process_files(config_files, &method(:uninstall_file))
  process_files(config_files(true), FISH_CONFIG_PATH, FISH_INSTALL_PATH, false, &method(:uninstall_file))
end

private

def process_files(files, source_path = ROOT_DIR, install_path = INSTALL_PATH, add_dot = true, &process)
  files.each do |file|
    filename = File.basename(file)
    filename = '.' + filename if add_dot
    destination = File.join(install_path, filename)
    absolute_destination = File.expand_path(destination)

    process.call(file, destination, absolute_destination)
  end
end

def config_files(is_fish = false)
  is_fish ?
    Dir[File.join(FISH_CONFIG_PATH, '*')]
    : Dir[File.join(ROOT_DIR, '*')].reject { |f| NON_CONFIG_FILES.include?(File.basename(f)) }
end

def uninstall_file(source, destination, absolute_destination)
  return unless File.identical?(source, absolute_destination) # skip files that were not previously installed

  @response = ask("remove #{destination}? [ynaq] ") unless @remove_all
  @remove_all ||= @response[/^a/i]

  case
    when @response[/^q/i]                 then exit
    when @remove_all || @response[/^y/i]  then unlink(destination)
  end
end

def install_file(source, destination, absolute_destination)
  return if File.identical?(source, absolute_destination) # skip files we already installed

  if File.exist?(absolute_destination)
    @response = ask("overwrite #{destination}? [ynaq] ") unless @replace_all
    @replace_all ||= @response[/^a/i]

    case
      when @response[/^q/i]                 then exit
      when @remove_all || @response[/^y/i]  then remove(absolute_destination)
      else return
    end
  end

  puts "linking #{destination}"
  File.symlink(source, absolute_destination)
end

def remove(file)
  sh %[rm -rf "#{absolute_destination}"]
end

def unlink(filename)
  puts "unlinking #{filename}"
  File.unlink(File.expand_path(filename))
end

def ask(*args)
    print(*args)
    $stdin.gets.chomp
end
