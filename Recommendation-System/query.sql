SELECT projects.id as id,author_id,projects.name,description,
        array_agg(tags.name) as tag_names, view, count(stars.id) as star_count from projects
        LEFT JOIN taggings ON taggings.project_id = projects.id
        LEFT JOIN tags ON tags.id = taggings.tag_id
        LEFT JOIN stars ON projects.id = stars.project_id
        where projects.project_access_type = 'Public' and
        projects.forked_project_id is NULL
        GROUP BY projects.id;