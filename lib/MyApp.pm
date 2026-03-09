package MyApp;
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
            'title'   => 'MyApp - Error',
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
            'title'   => 'MyApp - Query Error',
            'version' => 'Query failed. Please check logs.'
        };
    }

    template 'index' => {
        'title'   => 'MyApp',
        'version' => $res->{version}
    };
};

1;
