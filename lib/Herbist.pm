package Herbist;
use Dancer2;
use Dancer2::Plugin::Database;

our $VERSION = '0.1';

get '/' => sub {
    my $db;
    eval {
        $db = database;
    };
    if ($@) {
        warning "Database connection failed: $@";
        return template 'index' => {
            'title'   => 'Herbist - Error',
            'version' => 'Database connection failed. Please check logs.'
        };
    }
    
    my $res;
    eval {
        $res = $db->selectrow_hashref("SELECT VERSION() as version");
    };
    if ($@) {
        warning "Database query failed: $@";
        return template 'index' => {
            'title'   => 'Herbist - Query Error',
            'version' => 'Query failed. Please check logs.'
        };
    }

    template 'index' => {
        'title'   => 'Herbist',
        'version' => $res->{version}
    };
};

1;
