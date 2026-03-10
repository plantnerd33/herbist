package Herbist;
use Dancer2;
use Dancer2::Plugin::Database;

use File::Spec;
use File::Copy;

our $VERSION = '0.1';

# GET route to list all herbs
get '/' => sub {
    my $db;
    eval {
        $db = database;
    };
    if ($@) {
        warning "Database connection failed: $@";
        return template 'index' => {
            'title'   => 'Herbist - Error',
            'version' => 'Database connection failed. Please check logs.',
            'herbs'   => []
        };
    }
    
    my $res;
    my $herbs = [];
    eval {
        $res = $db->selectrow_hashref("SELECT VERSION() as version");
        $herbs = $db->selectall_arrayref("SELECT * FROM herb", { Slice => {} });
    };
    if ($@) {
        warning "Database query failed: $@";
        return template 'index' => {
            'title'   => 'Herbist - Query Error',
            'version' => 'Query failed. Please check logs.',
            'herbs'   => []
        };
    }

    template 'index' => {
        'title'   => 'Herbist',
        'version' => $res->{version},
        'herbs'   => $herbs
    };
};

# POST route to handle image uploads for a specific herb
post '/upload/:id' => sub {
    my $id = route_parameters->get('id');
    my $file = request->upload('photo');

    if (!$file) {
        status 400;
        return "No photo uploaded.";
    }

    # Use public/uploads as the relative path
    my $upload_dir = File::Spec->catdir(config->{appdir}, 'public', 'uploads');
    mkdir $upload_dir unless -d $upload_dir;

    my $filename = "herb_${id}_" . $file->filename;
    my $destination = File::Spec->catfile($upload_dir, $filename);

    # Link for the DB and frontend (relative to public/)
    my $db_path = "uploads/$filename";

    if ($file->copy_to($destination)) {
        eval {
            database->quick_update('herb', { ID => $id }, { image_path => $db_path });
        };
        if ($@) {
            warning "Failed to update DB with image path: $@";
            return "Failed to update database.";
        }
        redirect '/';
    } else {
        status 500;
        return "Failed to save file.";
    }
};

1;
