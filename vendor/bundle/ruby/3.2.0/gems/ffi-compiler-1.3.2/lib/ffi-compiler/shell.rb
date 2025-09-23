require 'shellwords'
require 'rbconfig'

def shellescape(str)
    return str unless str
    if FFI::Platform::OS == 'windows'
        '"' + str.gsub('"', '""') + '"'
    else
        str.shellescape
    end
end

def shelljoin(args)
    if FFI::Platform::OS == 'windows'
        args.reduce { |cmd, arg| cmd + ' ' + shellescape(arg) }
    else
        args.shelljoin
    end
end

def shellsplit(str)
    return str unless str
    str.shellsplit
end
