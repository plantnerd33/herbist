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

# GET route to show the add herb form
get '/add' => sub {
    template 'add_herb' => { 'title' => 'Add New Herb' };
};

# POST route to process the add herb form
post '/add' => sub {
    my $params = body_parameters;
    
    eval {
        database->quick_insert('herb', {
            common_name => $params->get('common_name'),
            latin_name  => $params->get('latin_name'),
            description => $params->get('description'),
            synonyms    => $params->get('synonyms'),
            other_names => $params->get('other_names'),
            collection  => $params->get('collection'),
            uses        => $params->get('uses'),
            safety      => $params->get('safety'),
            dosage      => $params->get('dosage'),
        });
    };

    if ($@) {
        warning "Failed to insert herb: $@";
        return template 'add_herb' => { 
            'title' => 'Add New Herb',
            'error' => 'Failed to save herb to database.' 
        };
    }

    redirect '/';
};

# GET route to show herb details and manage supporting data
get '/herb/:id' => sub {
    my $id = route_parameters->get('id');
    my $db = database;
    
    my $herb = $db->quick_select('herb', { ID => $id });
    if (!$herb) {
        send_error("Herb not found", 404);
    }

    my $data = {
        herb => $herb,
        constituents => $db->selectall_arrayref("SELECT * FROM constituents WHERE herb_id = ?", { Slice => {} }, $id),
        actions      => $db->selectall_arrayref("SELECT * FROM actions WHERE herb_id = ?", { Slice => {} }, $id),
        energetics   => $db->selectall_arrayref("SELECT * FROM energetics WHERE herb_id = ?", { Slice => {} }, $id),
        indications  => $db->selectall_arrayref("SELECT * FROM indications WHERE herb_id = ?", { Slice => {} }, $id),
        plantfamily  => $db->selectall_arrayref("SELECT * FROM plantfamily WHERE herb_id = ?", { Slice => {} }, $id),
        bodysystems  => $db->selectall_arrayref("SELECT * FROM bodysystems WHERE herb_id = ?", { Slice => {} }, $id),
    };

    template 'manage_herb' => $data;
};

# POST route to add data to supporting tables
post '/herb/:id/add_data' => sub {
    my $id = route_parameters->get('id');
    my $table = body_parameters->get('table');
    my $name = body_parameters->get('name');

    my @allowed_tables = qw(constituents actions energetics indications plantfamily bodysystems);
    if (!grep { $_ eq $table } @allowed_tables) {
        send_error("Invalid table", 400);
    }

    eval {
        database->quick_insert($table, {
            herb_id => $id,
            name    => $name,
        });
    };

    if ($@) {
        warning "Failed to insert into $table: $@";
    }

    redirect "/herb/$id";
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
