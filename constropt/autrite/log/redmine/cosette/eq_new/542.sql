CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    "value" character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE attachments (
    id integer NOT NULL,
    container_id integer,
    container_type character varying(30),
    filename character varying    NOT NULL,
    disk_filename character varying    NOT NULL,
    filesize bigint   NOT NULL,
    content_type character varying   ,
    digest character varying(64)    NOT NULL,
    downloads integer   NOT NULL,
    author_id integer   NOT NULL,
    created_on timestamp without time zone,
    description character varying,
    disk_directory character varying
);

CREATE TABLE auth_sources (
    id integer NOT NULL,
    type character varying(30)    NOT NULL,
    name character varying(60)    NOT NULL,
    host character varying(60),
    port integer,
    account character varying,
    account_password character varying   ,
    base_dn character varying(255),
    attr_login character varying(30),
    attr_firstname character varying(30),
    attr_lastname character varying(30),
    attr_mail character varying(30),
    onthefly_register boolean   NOT NULL,
    tls boolean   NOT NULL,
    "filter" character varying(255),
    timeout integer,
    verify_peer boolean   NOT NULL
);

CREATE TABLE boards (
    id integer NOT NULL,
    project_id integer NOT NULL,
    name character varying    NOT NULL,
    description character varying,
    "position" integer,
    topics_count integer   NOT NULL,
    messages_count integer   NOT NULL,
    last_message_id integer,
    parent_id integer
);

CREATE TABLE changes (
    id integer NOT NULL,
    changeset_id integer NOT NULL,
    action character varying(1)    NOT NULL,
    path character varying(255) NOT NULL,
    from_path character varying(255),
    from_revision character varying,
    revision character varying,
    branch character varying
);

CREATE TABLE changeset_parents (
    changeset_id integer NOT NULL,
    parent_id integer NOT NULL
);

CREATE TABLE changesets (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    revision character varying NOT NULL,
    committer character varying,
    committed_on timestamp without time zone NOT NULL,
    comments character varying(255),
    commit_date date,
    scmid character varying,
    user_id integer
);

CREATE TABLE changesets_issues (
    changeset_id integer NOT NULL,
    issue_id integer NOT NULL
);

CREATE TABLE comments (
    id integer NOT NULL,
    commented_type character varying(30)    NOT NULL,
    commented_id integer   NOT NULL,
    author_id integer   NOT NULL,
    content character varying(255),
    created_on timestamp without time zone NOT NULL,
    updated_on timestamp without time zone NOT NULL
);

CREATE TABLE custom_field_enumerations (
    id integer NOT NULL,
    custom_field_id integer NOT NULL,
    name character varying NOT NULL,
    active boolean   NOT NULL,
    "position" integer   NOT NULL
);

CREATE TABLE custom_fields (
    id integer NOT NULL,
    type character varying(30)    NOT NULL,
    name character varying(30)    NOT NULL,
    field_format character varying(30)    NOT NULL,
    possible_values character varying(255),
    regexp character varying   ,
    min_length integer,
    max_length integer,
    is_required boolean   NOT NULL,
    is_for_all boolean   NOT NULL,
    is_filter boolean   NOT NULL,
    "position" integer,
    searchable boolean  ,
    -- "default_value" character varying(255),
    editable boolean  ,
    visible boolean   NOT NULL,
    multiple boolean  ,
    format_store character varying(255),
    description character varying(255)
);

CREATE TABLE custom_fields_projects (
    custom_field_id integer   NOT NULL,
    project_id integer   NOT NULL
);

CREATE TABLE custom_fields_roles (
    custom_field_id integer NOT NULL,
    role_id integer NOT NULL
);

CREATE TABLE custom_fields_trackers (
    custom_field_id integer   NOT NULL,
    tracker_id integer   NOT NULL
);

CREATE TABLE custom_values (
    id integer NOT NULL,
    customized_type character varying(30)    NOT NULL,
    customized_id integer   NOT NULL,
    custom_field_id integer   NOT NULL,
    "value" character varying(255)
);

CREATE TABLE documents (
    id integer NOT NULL,
    project_id integer   NOT NULL,
    category_id integer   NOT NULL,
    title character varying    NOT NULL,
    description character varying(255),
    created_on timestamp without time zone
);

CREATE TABLE email_addresses (
    id integer NOT NULL,
    user_id integer NOT NULL,
    address character varying NOT NULL,
    is_default boolean   NOT NULL,
    notify boolean   NOT NULL,
    created_on timestamp without time zone NOT NULL,
    updated_on timestamp without time zone NOT NULL
);

CREATE TABLE enabled_modules (
    id integer NOT NULL,
    project_id integer,
    name character varying NOT NULL
);

CREATE TABLE enumerations (
    id integer NOT NULL,
    name character varying(30)    NOT NULL,
    "position" integer,
    is_default boolean   NOT NULL,
    type character varying,
    active boolean   NOT NULL,
    project_id integer,
    parent_id integer,
    position_name character varying(30)
);

CREATE TABLE groups_users (
    group_id integer NOT NULL,
    user_id integer NOT NULL
);

CREATE TABLE import_items (
    id integer NOT NULL,
    import_id integer NOT NULL,
    "position" integer NOT NULL,
    obj_id integer,
    message character varying(255),
    unique_id character varying
);

CREATE TABLE imports (
    id integer NOT NULL,
    type character varying,
    user_id integer NOT NULL,
    filename character varying,
    settings character varying(255),
    total_items integer,
    finished boolean   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE issue_categories (
    id integer NOT NULL,
    project_id integer   NOT NULL,
    name character varying(60)    NOT NULL,
    assigned_to_id integer
);

CREATE TABLE issue_relations (
    id integer NOT NULL,
    issue_from_id integer NOT NULL,
    issue_to_id integer NOT NULL,
    relation_type character varying    NOT NULL,
    delay integer
);

CREATE TABLE issue_statuses (
    id integer NOT NULL,
    name character varying(30)    NOT NULL,
    is_closed boolean   NOT NULL,
    "position" integer,
    default_done_ratio integer
);

CREATE TABLE issues (
    id integer NOT NULL,
    tracker_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying    NOT NULL,
    description character varying(255),
    due_date date,
    category_id integer,
    status_id integer NOT NULL,
    assigned_to_id integer,
    priority_id integer NOT NULL,
    fixed_version_id integer,
    author_id integer NOT NULL,
    lock_version integer   NOT NULL,
    created_on timestamp without time zone,
    updated_on timestamp without time zone,
    start_date date,
    done_ratio integer   NOT NULL,
    estimated_hours double precision,
    parent_id integer,
    root_id integer,
    lft integer,
    rgt integer,
    is_private boolean   NOT NULL,
    closed_on timestamp without time zone
);

CREATE TABLE journal_details (
    id integer NOT NULL,
    journal_id integer   NOT NULL,
    property character varying(30)    NOT NULL,
    prop_key character varying(30)    NOT NULL,
    old_value character varying(255),
    "value" character varying(255)
);

CREATE TABLE journals (
    id integer NOT NULL,
    journalized_id integer   NOT NULL,
    journalized_type character varying(30)    NOT NULL,
    user_id integer   NOT NULL,
    notes character varying(255),
    created_on timestamp without time zone NOT NULL,
    private_notes boolean   NOT NULL
);

CREATE TABLE member_roles (
    id integer NOT NULL,
    member_id integer NOT NULL,
    role_id integer NOT NULL,
    inherited_from integer
);

CREATE TABLE members (
    id integer NOT NULL,
    user_id integer   NOT NULL,
    project_id integer   NOT NULL,
    created_on timestamp without time zone,
    mail_notification boolean   NOT NULL
);

CREATE TABLE messages (
    id integer NOT NULL,
    board_id integer NOT NULL,
    parent_id integer,
    subject character varying    NOT NULL,
    content character varying(255),
    author_id integer,
    replies_count integer   NOT NULL,
    last_reply_id integer,
    created_on timestamp without time zone NOT NULL,
    updated_on timestamp without time zone NOT NULL,
    locked boolean  ,
    sticky integer  
);

CREATE TABLE news (
    id integer NOT NULL,
    project_id integer,
    title character varying(60)    NOT NULL,
    summary character varying(255)   ,
    description character varying(255),
    author_id integer   NOT NULL,
    created_on timestamp without time zone,
    comments_count integer   NOT NULL
);

CREATE TABLE open_id_authentication_associations (
    id integer NOT NULL,
    issued integer,
    lifetime integer,
    handle character varying,
    assoc_type character varying,
    server_url binary(255),
    secret binary(255)
);

CREATE TABLE open_id_authentication_nonces (
    id integer NOT NULL,
    "timestamp" integer NOT NULL,
    server_url character varying,
    salt character varying NOT NULL
);

CREATE TABLE projects (
    id integer NOT NULL,
    name character varying    NOT NULL,
    description character varying(255),
    homepage character varying   ,
    is_public boolean   NOT NULL,
    parent_id integer,
    created_on timestamp without time zone,
    updated_on timestamp without time zone,
    identifier character varying,
    status integer   NOT NULL,
    lft integer,
    rgt integer,
    inherit_members boolean   NOT NULL,
    default_version_id integer,
    default_assigned_to_id integer
);

CREATE TABLE projects_trackers (
    project_id integer   NOT NULL,
    tracker_id integer   NOT NULL
);

CREATE TABLE queries (
    id integer NOT NULL,
    project_id integer,
    name character varying    NOT NULL,
    filters character varying(255),
    user_id integer   NOT NULL,
    column_names character varying(255),
    sort_criteria character varying(255),
    group_by character varying,
    type character varying,
    visibility integer  ,
    options character varying(255)
);

CREATE TABLE queries_roles (
    query_id integer NOT NULL,
    role_id integer NOT NULL
);

CREATE TABLE repositories (
    id integer NOT NULL,
    project_id integer   NOT NULL,
    url character varying    NOT NULL,
    login character varying(60)   ,
    password character varying   ,
    root_url character varying(255)   ,
    type character varying,
    path_encoding character varying(64)   ,
    log_encoding character varying(64)   ,
    extra_info character varying(255),
    identifier character varying,
    is_default boolean  ,
    created_on timestamp without time zone
);

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255)    NOT NULL,
    "position" integer,
    assignable boolean  ,
    builtin integer   NOT NULL,
    permissions character varying(255),
    issues_visibility character varying(30)    NOT NULL,
    users_visibility character varying(30)    NOT NULL,
    time_entries_visibility character varying(30)    NOT NULL,
    all_roles_managed boolean   NOT NULL,
    settings character varying(255)
);

CREATE TABLE roles_managed_roles (
    role_id integer NOT NULL,
    managed_role_id integer NOT NULL
);

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);

CREATE TABLE settings (
    id integer NOT NULL,
    name character varying(255)    NOT NULL,
    "value" character varying(255),
    updated_on timestamp without time zone
);

CREATE TABLE time_entries (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    issue_id integer,
    hours double precision NOT NULL,
    comments character varying(1024),
    activity_id integer NOT NULL,
    spent_on date NOT NULL,
    tyear integer NOT NULL,
    tmonth integer NOT NULL,
    tweek integer NOT NULL,
    created_on timestamp without time zone NOT NULL,
    updated_on timestamp without time zone NOT NULL,
    author_id integer
);

CREATE TABLE tokens (
    id integer NOT NULL,
    user_id integer   NOT NULL,
    action character varying(30)    NOT NULL,
    "value" character varying(40)    NOT NULL,
    created_on timestamp without time zone NOT NULL,
    updated_on timestamp without time zone
);

CREATE TABLE trackers (
    id integer NOT NULL,
    name character varying(30)    NOT NULL,
    is_in_chlog boolean   NOT NULL,
    "position" integer,
    is_in_roadmap boolean   NOT NULL,
    fields_bits integer  ,
    default_status_id integer,
    description character varying
);

CREATE TABLE user_preferences (
    id integer NOT NULL,
    user_id integer   NOT NULL,
    others character varying(255),
    hide_mail boolean  ,
    time_zone character varying
);

CREATE TABLE users (
    id integer NOT NULL,
    login character varying    NOT NULL,
    hashed_password character varying(40)    NOT NULL,
    firstname character varying(30)    NOT NULL,
    lastname character varying(255)    NOT NULL,
    admin boolean   NOT NULL,
    status integer   NOT NULL,
    last_login_on timestamp without time zone,
    "language" character varying(5)   ,
    auth_source_id integer,
    created_on timestamp without time zone,
    updated_on timestamp without time zone,
    type character varying,
    identity_url character varying,
    mail_notification character varying    NOT NULL,
    salt character varying(64),
    must_change_passwd boolean   NOT NULL,
    passwd_changed_on timestamp without time zone,
    twofa_scheme character varying,
    twofa_totp_key character varying,
    twofa_totp_last_used_at integer
);

CREATE TABLE versions (
    id integer NOT NULL,
    project_id integer   NOT NULL,
    name character varying    NOT NULL,
    description character varying   ,
    effective_date date,
    created_on timestamp without time zone,
    updated_on timestamp without time zone,
    wiki_page_title character varying,
    status character varying   ,
    sharing character varying    NOT NULL
);

CREATE TABLE watchers (
    id integer NOT NULL,
    watchable_type character varying    NOT NULL,
    watchable_id integer   NOT NULL,
    user_id integer
);

CREATE TABLE wiki_content_versions (
    id integer NOT NULL,
    wiki_content_id integer NOT NULL,
    page_id integer NOT NULL,
    author_id integer,
    data binary(255),
    compression character varying(6)   ,
    comments character varying(1024)   ,
    updated_on timestamp without time zone NOT NULL,
    version integer NOT NULL
);

CREATE TABLE wiki_contents (
    id integer NOT NULL,
    page_id integer NOT NULL,
    author_id integer,
    -- character varying(255) text,
    comments character varying(1024)   ,
    updated_on timestamp without time zone NOT NULL,
    version integer NOT NULL
);

CREATE TABLE wiki_pages (
    id integer NOT NULL,
    wiki_id integer NOT NULL,
    title character varying(255) NOT NULL,
    created_on timestamp without time zone NOT NULL,
    protected boolean   NOT NULL,
    parent_id integer
);

CREATE TABLE wiki_redirects (
    id integer NOT NULL,
    wiki_id integer NOT NULL,
    title character varying,
    redirects_to character varying,
    created_on timestamp without time zone NOT NULL,
    redirects_to_wiki_id integer NOT NULL
);

CREATE TABLE wikis (
    id integer NOT NULL,
    project_id integer NOT NULL,
    start_page character varying(255) NOT NULL,
    status integer   NOT NULL
);

CREATE TABLE workflows (
    id integer NOT NULL,
    tracker_id integer   NOT NULL,
    old_status_id integer   NOT NULL,
    new_status_id integer   NOT NULL,
    role_id integer   NOT NULL,
    assignee boolean   NOT NULL,
    author boolean   NOT NULL,
    type character varying(30),
    field_name character varying(30),
    rule character varying(30)
);
-- Original Query
SELECT DISTINCT trackers.* FROM trackers INNER JOIN projects_trackers ON projects_trackers.tracker_id = trackers.id INNER JOIN projects ON projects.id = projects_trackers.project_id WHERE projects.status <> 9 AND (SELECT 1 AS "one" FROM enabled_modules AS em WHERE em.project_id = projects.id AND em.name = 'issue_tracking') IS NOT NULL AND projects.is_public = True AND projects.id NOT IN (SELECT project_id FROM members WHERE user_id IN (6, 13)) ORDER BY trackers.position ASC;
-- Rewritten Queries
SELECT DISTINCT trackers.* FROM trackers INNER JOIN projects_trackers ON projects_trackers.tracker_id = trackers.id INNER JOIN projects ON projects.id = projects_trackers.project_id WHERE projects.status <> 9 AND (SELECT 1 AS "one" FROM enabled_modules AS em WHERE em.project_id = projects.id AND em.name = 'issue_tracking') IS NOT NULL AND projects.is_public = True AND projects.id NOT IN (SELECT project_id FROM members WHERE user_id IN (6, 13) LIMIT 1) ORDER BY trackers.position ASC;
SELECT DISTINCT trackers.* FROM trackers INNER JOIN projects_trackers ON projects_trackers.tracker_id = trackers.id INNER JOIN projects ON projects.id = projects_trackers.project_id WHERE projects.status <> 9 AND (SELECT 1 AS "one" FROM enabled_modules AS em WHERE em.project_id = projects.id AND em.name = 'issue_tracking' LIMIT 1) IS NOT NULL AND projects.is_public = True AND projects.id NOT IN (SELECT project_id FROM members WHERE user_id IN (6, 13) LIMIT 1) ORDER BY trackers.position ASC;
