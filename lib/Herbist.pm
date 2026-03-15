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
    my $db = database;
    my $data = { title => 'Add New Herb' };
    
    # Fetch unique names for multiselect options
    for my $table (qw(constituents actions energetics indications plantfamily bodysystems)) {
        $data->{$table} = $db->selectcol_arrayref("SELECT DISTINCT name FROM $table ORDER BY name");
    }

    template 'add_herb' => $data;
};

# GET route to show the edit herb form
get '/herb/:id/edit' => sub {
    my $id = route_parameters->get('id');
    my $db = database;
    my $herb = $db->quick_select('herb', { ID => $id });
    if (!$herb) { send_error("Herb not found", 404) }

    my $data = { herb => $herb, title => 'Edit Herb' };
    
    # Fetch all unique names (for options) AND current associations (for selection)
    for my $table (qw(constituents actions energetics indications plantfamily bodysystems)) {
        $data->{"all_$table"} = $db->selectcol_arrayref("SELECT DISTINCT name FROM $table ORDER BY name");
        $data->{"current_$table"} = $db->selectcol_arrayref("SELECT name FROM $table WHERE herb_id = ?", undef, $id);
    }

    template 'edit_herb' => $data;
};

# POST route to process herb update
post '/herb/:id/edit' => sub {
    my $id = route_parameters->get('id');
    my $params = body_parameters;
    my $db = database;
    
    eval {
        $db->quick_update('herb', { ID => $id }, {
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

        # Update supporting tables: Delete old and insert new (from multiselect and new text input)
        for my $table (qw(constituents actions energetics indications plantfamily bodysystems)) {
            $db->quick_delete($table, { herb_id => $id });
            
            my @names = $params->get_all("select_$table");
            if (my $new = $params->get("new_$table")) {
                push @names, split(/\s*,\s*/, $new);
            }
            
            for my $name (grep { length($_) } @names) {
                $db->quick_insert($table, { herb_id => $id, name => $name });
            }
        }
    };

    if ($@) {
        warning "Failed to update herb: $@";
        redirect "/herb/$id/edit";
    }
    redirect "/herb/$id";
};

# POST route to delete a herb
post '/herb/:id/delete' => sub {
    my $id = route_parameters->get('id');
    eval { database->quick_delete('herb', { ID => $id }) };
    redirect '/';
};

# GET route to show the edit form for supporting data
get '/data/:table/:id/edit' => sub {
    my $table = route_parameters->get('table');
    my $id = route_parameters->get('id');
    
    my @allowed_tables = qw(constituents actions energetics indications plantfamily bodysystems);
    if (!grep { $_ eq $table } @allowed_tables) {
        send_error("Invalid table", 400);
    }

    my $item = database->quick_select($table, { ID => $id });
    if (!$item) { send_error("Item not found", 404) }

    template 'edit_data' => { 
        item  => $item, 
        table => $table,
        title => "Edit " . ucfirst($table)
    };
};

# POST route to update supporting data
post '/data/:table/:id/edit' => sub {
    my $table = route_parameters->get('table');
    my $id = route_parameters->get('id');
    my $name = body_parameters->get('name');
    my $herb_id = body_parameters->get('herb_id');
    my $from_manage = body_parameters->get('from_manage');

    my @allowed_tables = qw(constituents actions energetics indications plantfamily bodysystems);
    if (grep { $_ eq $table } @allowed_tables) {
        eval {
            database->quick_update($table, { ID => $id }, { name => $name });
        };
    }

    redirect $from_manage ? "/manage/$table" : "/herb/$herb_id";
};

# POST route to delete supporting data
post '/data/:table/:id/delete' => sub {
    my $table = route_parameters->get('table');
    my $id = route_parameters->get('id');
    my $herb_id = body_parameters->get('herb_id');

    my @allowed_tables = qw(constituents actions energetics indications plantfamily bodysystems);
    if (grep { $_ eq $table } @allowed_tables) {
        eval { database->quick_delete($table, { ID => $id }) };
    }
    
    # If we have a referrer or explicitly come from management
    my $referer = request->referer || '';
    if ($referer =~ /\/manage\//) {
        redirect "/manage/$table";
    }
    redirect $herb_id ? "/herb/$herb_id" : "/data_entry";
};

# POST route to process the add herb form
post '/add' => sub {
    my $params = body_parameters;
    my $db = database;
    my $new_id;
    
    eval {
        $db->quick_insert('herb', {
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
        $new_id = $db->last_insert_id;

        # Insert supporting data
        for my $table (qw(constituents actions energetics indications plantfamily bodysystems)) {
            my @names = $params->get_all("select_$table");
            if (my $new = $params->get("new_$table")) {
                push @names, split(/\s*,\s*/, $new);
            }
            
            for my $name (grep { length($_) } @names) {
                $db->quick_insert($table, { herb_id => $new_id, name => $name });
            }
        }
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

# GET route for managing a specific supporting table
get '/manage/:table' => sub {
    my $table = route_parameters->get('table');
    my $db = database;
    
    my @allowed_tables = qw(constituents actions energetics indications plantfamily bodysystems);
    if (!grep { $_ eq $table } @allowed_tables) {
        send_error("Invalid table", 400);
    }

    # Fetch all items with their associated herb name (using LEFT JOIN)
    my $items = $db->selectall_arrayref(
        "SELECT t.*, h.common_name as herb_name FROM $table t LEFT JOIN herb h ON t.herb_id = h.ID ORDER BY t.name",
        { Slice => {} }
    );

    # Fetch all herbs for the "Add" dropdown
    my $herbs = $db->selectall_arrayref("SELECT ID, common_name FROM herb ORDER BY common_name", { Slice => {} });

    template 'manage_table' => {
        table => $table,
        items => $items,
        herbs => $herbs,
        title => "Manage " . ucfirst($table)
    };
};

# POST route to add data from the management page
post '/manage/:table/add' => sub {
    my $table = route_parameters->get('table');
    my $name = body_parameters->get('name');

    eval {
        database->quick_insert($table, {
            herb_id => undef,
            name    => $name,
        });
    };

    redirect "/manage/$table";
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
