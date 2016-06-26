#!/usr/bin/env ruby
require 'net/ssh'
require 'shellwords'

ssh_user = ENV['ssh_user']
ssh_host = ENV['ssh_host']
ssh_port = ENV['ssh_port']
ssh_dir = ENV['ssh_dir']
ssh_key = ENV['ssh_key']
mnt = ENV['mnt']
uid = ENV['uid']
gid = ENV['gid']

def set_ssh_key(ssh_key)
  id_rsa = '/root/.ssh/id_rsa'
  f = File.open( id_rsa,"w" )
  f << ssh_key
  f.chmod(0600)
  f.close
end

def get_remote_file_list(ssh_host, ssh_port, ssh_user, ssh_dir)
  Net::SSH.start(ssh_host, ssh_user, port: ssh_port, :paranoid => Net::SSH::Verifiers::Null.new) do |ssh|
    stdout = ''
    ssh.exec!("find #{ssh_dir} -maxdepth 1") do |_channel, stream, data|
      stdout << data if stream == :stdout
    end

    stdout = stdout.split(/\n/)
  end
end

def sync_remote_to_local_tmp(ssh_host, ssh_port, ssh_user, ssh_dir, mnt, uid, gid)
  get_remote_file_list(ssh_host, ssh_port, ssh_user, ssh_dir).each do |entry|
    next if ssh_dir == entry
    remote_path = Shellwords.escape(entry)
    fail 'exiting because remote_path is /! please check your ssh_dir variable' if remote_path == '/'
    system("rsync -avz -e 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p#{ssh_port}' #{ssh_user}@#{ssh_host}:'#{remote_path}' #{mnt}")
    system("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p #{ssh_port} #{ssh_user}@#{ssh_host} rm -fr '#{remote_path}'")
    filename = remote_path.gsub(ssh_dir, '')
    set_permissions(mnt, filename, uid, gid)
  end
end

def set_permissions(mnt, filename, uid, gid)
  system("chown -R #{uid}:#{gid} #{mnt}/#{filename}")
end

set_ssh_key(ssh_key)

loop do
  sync_remote_to_local_tmp(ssh_host, ssh_port, ssh_user, ssh_dir, mnt, uid, gid)
  sleep 10
end
