require 'win32/registry'

COMPILE_TARGET = ENV['config'].nil? ? "debug" : ENV['config']
BUILD_VERSION = '100.0.0'
tc_build_number = ENV["BUILD_NUMBER"]
build_revision = tc_build_number || Time.new.strftime('5%H%M')
build_number = "#{BUILD_VERSION}.#{build_revision}"
BUILD_NUMBER = build_number 

desc 'Compile the code'
task :compile => [:clean, :version] do
  msbuildExePath = getMsbuildToolsPath("14.0")
  sh "#{msbuildExePath} src/FubuCore.sln /property:Configuration=#{COMPILE_TARGET} /v:m /t:rebuild /nr:False /maxcpucount:8"
end

desc 'Run the unit tests'
task :test => [:compile] do
  sh "src/packages/NUnit.ConsoleRunner.3.6.1/tools/nunit3-console.exe src/fubucore.testing/bin/#{COMPILE_TARGET}/fubucore.Testing.dll"
end

desc "Prepares the working directory for a new build"
task :clean do
  FileUtils.rm_rf 'artifacts'
  Dir.mkdir 'artifacts'
end


desc "Update the version information for the build"
task :version do
  asm_version = build_number
  
  begin
    commit = `git log -1 --pretty=format:%H`
  rescue
    commit = "git unavailable"
  end
  puts "##teamcity[buildNumber '#{build_number}']" unless tc_build_number.nil?
  puts "Version: #{build_number}" if tc_build_number.nil?
  
  options = {
    :description => 'FubuCore',
    :product_name => 'FubuCore',
    :copyright => 'Copyright 2008-2013 Jeremy D. Miller, Josh Arnold, Joshua Flanagan, et al. All rights reserved.',
    :trademark => commit,
    :version => asm_version,
    :file_version => build_number,
    :informational_version => asm_version
  }
  
  puts "Writing src/CommonAssemblyInfo.cs..."
  File.open('src/CommonAssemblyInfo.cs', 'w') do |file|
    file.write "using System.Reflection;\n"
    file.write "using System.Runtime.InteropServices;\n"
    file.write "[assembly: AssemblyDescription(\"#{options[:description]}\")]\n"
    file.write "[assembly: AssemblyProduct(\"#{options[:product_name]}\")]\n"
    file.write "[assembly: AssemblyCopyright(\"#{options[:copyright]}\")]\n"
    file.write "[assembly: AssemblyTrademark(\"#{options[:trademark]}\")]\n"
    file.write "[assembly: AssemblyVersion(\"#{options[:version]}\")]\n"
    file.write "[assembly: AssemblyFileVersion(\"#{options[:file_version]}\")]\n"
    file.write "[assembly: AssemblyInformationalVersion(\"#{options[:informational_version]}\")]\n"
  end
end


def self.getMsbuildToolsPath(msbuildToolsVersion)
  # Try the old way to find MSBuild 14.0
  Win32::Registry::HKEY_LOCAL_MACHINE.open("Software\\Microsoft\\MSBuild\\ToolsVersions") do |reg|
    reg.each_key do |k,v|
      next unless (k.downcase == msbuildToolsVersion.downcase)
      reg.open(k) do |subkey|
        exePath = subkey['MSBuildToolsPath']
        return "\"#{exePath}msbuild.exe\""
      end
    end
  end

  puts "Didn't find MSBuild 14 in the registry. Attempting to find MSBuild 15 in Visual Studio install folder"

  # Try the new way with VS2017 and VS2019 to find MSBuild 15
  vs_install_path = `"C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer\\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`
  puts "Visual Studio install path found: #{vs_install_path}"
  vs_install_path = vs_install_path.chomp
  return "\"#{vs_install_path}\\MSBuild\\15.0\\Bin\"msbuild.exe\\"
end