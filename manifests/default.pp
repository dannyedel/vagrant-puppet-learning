# Apt sources

class { 'apt':
	proxy_host => "10.54.5.11",
	proxy_port => "3142",
	#old syntax
	purge_sources_list   => true,
	purge_sources_list_d => true,
	#	purge_preferences    => true,
	#purge_preferences_d  => true,
	# new syntax
	#purge             => {
	#	'sources.list'   => true,
	#	'sources.list.d' => true,
	#	'preferences'    => true,
	#	'preferences.d'  => true,
	#},
}

apt::source { 'debian_jessie':
	location => 'http://ftp2.de.debian.org/debian',
	release  => 'jessie',
	repos    => 'main',
}

apt::source { 'danny_backports':
	location => 'http://danny-edel.de/packages',
	release  => 'jessie-backports/',
	repos    => '',
}

apt::conf{ 'norecommends':
	content => 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";',
	ensure  => present,
}

package { [
	'ntp',
	'rng-tools',
	'vim',
	]:
	ensure => latest,
}

# Set blank password for root.
# This allows local login at console from the
# hypervisor.
#
# Also, delete all SSH keys not managed via puppet.
user { 'root':
	ensure         => present,
	shell          => '/bin/bash',
	home           => '/root',
	password       => '',
	purge_ssh_keys => true,
}

augeas { 'sshd_config' :
	context => '/files/etc/ssh/sshd_config',
	changes => [
		"set PasswordAuthentication no",
	],
}

service { 'sshd' :
	ensure => running,
	subscribe => Augeas['sshd_config'],
}

ssh_authorized_key { 'danny' :
	user => root,
	type => ssh-rsa,
	ensure => present,
	key => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDP+sbYC+TSf7VNNZVUsIhZFoZ3+XHn81ptTaPop+8xMOO4Ft6T7VKh5gX2MenYnJHCSze8P3aOao1XIiQdqZY9xfa/sx4ceS6mItcCBx7haBkvoyp/DGaq7/EvMMM4f9K4xZwvozFiNbsjzPu8Dno2M8drSkiWjo3g685A3oX5k+USnR4jIPPTAgDJFzSO1+W7xPtBZ8lbRjyWSH9p46XaPOXLURd2oiNITMRE4wrcstu04Evg9ls6QuLqFFdwyMO0Zbg80qZicoV711SLT5zfojpVj2zWP7r/IOxrEe+x0nisgb5bvmfFqq/rViE1bS20io5OebGbSz8JXsKj1DupDy1fAPO+RhlnIsg4FV1ohG/p32D6I3V+zEjyRO4WcSInsUUMx76nCipeOdg7OYOiUsNPrQo36XvWAyN7yXYEEGc9EQNXU2GHjM0gtly3bbCzgHQ0e/XOf4nUDmCuUe92WeHeycN6odOjODv2qkgkk4INdyJ83rUt8AtjohzJM8G+BcXuKIJneUyH3kSWfi4pFtbbt283AblxFdJXnkUp330pbUDD3wCjTUjHSQDda4p68GAcdnnsoMMJx0It/C0O974k+sY67bUeR+D5WadM7xs6U55fJ+s9a+8Ko9jhNIY4MnZp/bKLY2hQrw/SO3ISDP3TTx/f8S+idnWA25R/sw=='
}
