client.rb:
	echo cookbook_path '"$$(pwd)/cookbooks"' >client.rb
	echo encrypted_data_bag_secret '"$$HOME/.chef/encrypted_data_bag_secret"' >>client.rb
	echo 'log_location STDOUT' >>client.rb

vendor:
	rm -rf cookbooks/ local-mode-cache/
	berks install
	berks upload --no-freeze chef_wordpress
	berks vendor cookbooks

pretty:
	terraform fmt

clean:
	rm -rf cookbooks/
	rm -rf local-mode-cache/
	rm -rf nodes/
	rm -f errored.tfstate
	rm -f client.rb
	rm -f dna*.json
	rm -f *.tvars
