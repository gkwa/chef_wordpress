describe service('nginx') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end

describe command('curl http://localhost') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/Welcome to /) }
end

describe command('curl http://localhost/phpinfo.php') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/PHP Version/) }
end

describe command('curl http://localhost/wordpress') do
  its('stdout') { should match(/301 Moved Permanently/) }
end

describe command('curl -L http://localhost/wordpress') do
  its('stdout') { should match(/Error establishing a database connection/) }
end
