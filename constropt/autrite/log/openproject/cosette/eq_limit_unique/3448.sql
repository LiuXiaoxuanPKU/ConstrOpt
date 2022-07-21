CREATE TABLE announcements (
    id integer NOT NULL,
    character varying(255) text,
    show_until date,
    active boolean  ,
    created_at timestamp without time zone,
updated_at timestamp without time zone,
);

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    "value" character varying,
    created_at timestamp(6) without time zone NOT NULL,
updated_at timestamp(6) without time zone NOT NULL,
);

CREATE TABLE attachable_journals (
    id integer NOT NULL,
    journal_id integer NOT NULL,
    attachment_id integer NOT NULL,
filename character varying    NOT NULL,
);

CREATE TABLE attachment_journals (
    id integer NOT NULL,
    container_id integer,
    container_type character varying(30),
    filename character varying    NOT NULL,
    disk_filename character varying    NOT NULL,
    filesize bigint   NOT NULL,
    content_type character varying   ,
    digest character varying(40)    NOT NULL,
    downloads integer   NOT NULL,
    author_id integer   NOT NULL,
description character varying(255),
);

CREATE TABLE attachments (
    id integer NOT NULL,
    container_id integer,
    container_type character varying(30),
    filename character varying    NOT NULL,
    disk_filename character varying    NOT NULL,
    filesize bigint   NOT NULL,
    content_type character varying   ,
    digest character varying(40)    NOT NULL,
    downloads integer   NOT NULL,
    author_id integer   NOT NULL,
    created_at timestamp without time zone,
    description character varying,
    file character varying,
    fulltext character varying(255),
    fulltext_tsv tsvector,
    file_tsv tsvector,
updated_at timestamp without time zone,
);

CREATE TABLE attribute_help_texts (
    id integer NOT NULL,
    help_text character varying(255) NOT NULL,
    type character varying NOT NULL,
    attribute_name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
UNIQUE(attribute_name,type),
);

CREATE TABLE auth_sources (
    id integer NOT NULL,
    type character varying(30)    NOT NULL,
    name character varying(60)    NOT NULL,
    host character varying(60),
    port integer,
    account character varying,
    account_password character varying   ,
    base_dn character varying,
    attr_login character varying(30),
    attr_firstname character varying(30),
    attr_lastname character varying(30),
    attr_mail character varying(30),
    onthefly_register boolean   NOT NULL,
    attr_admin character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tls_mode integer   NOT NULL,
filter_string character varying(255),
UNIQUE(name),
);

CREATE TABLE bcf_comments (
    id bigint NOT NULL,
    uuid character varying(255),
    journal_id bigint,
    issue_id bigint,
viewpoint_id bigint,
);

CREATE TABLE bcf_issues (
    id bigint NOT NULL,
    uuid character varying(255),
    markup xml,
    work_package_id bigint,
    stage character varying,
    index integer,
    labels text[]  ,
    created_at timestamp(6) without time zone   NOT NULL,
updated_at timestamp(6) without time zone   NOT NULL,
);

CREATE TABLE bcf_viewpoints (
    id bigint NOT NULL,
    uuid character varying(255),
    viewpoint_name character varying(255),
    issue_id bigint,
    json_viewpoint jsonb,
    created_at timestamp(6) without time zone   NOT NULL,
updated_at timestamp(6) without time zone   NOT NULL,
);

CREATE TABLE budget_journals (
    id integer NOT NULL,
    project_id integer NOT NULL,
    author_id integer NOT NULL,
    subject character varying NOT NULL,
    description character varying(255),
fixed_date date NOT NULL,
);

CREATE TABLE budgets (
    id integer NOT NULL,
    project_id integer NOT NULL,
    author_id integer NOT NULL,
    subject character varying NOT NULL,
    description character varying(255) NOT NULL,
    fixed_date date NOT NULL,
    created_at timestamp without time zone,
updated_at timestamp without time zone,
);

CREATE TABLE categories (
    id integer NOT NULL,
    project_id integer   NOT NULL,
    name character varying(256)    NOT NULL,
    assigned_to_id integer,
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
UNIQUE(name,project_id),
);

CREATE TABLE changes (
    id integer NOT NULL,
    changeset_id integer NOT NULL,
    action character varying(1)    NOT NULL,
    path character varying(255) NOT NULL,
    from_path character varying(255),
    from_revision character varying,
    revision character varying,
branch character varying,
);

CREATE TABLE changeset_journals (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    revision character varying NOT NULL,
    committer character varying,
    committed_on timestamp without time zone NOT NULL,
    comments character varying(255),
    commit_date date,
    scmid character varying,
user_id integer,
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
user_id integer,
UNIQUE(scmid,repository_id),
UNIQUE(repository_id,revision),
UNIQUE(revision,repository_id),
);

CREATE TABLE changesets_work_packages (
    changeset_id integer NOT NULL,
work_package_id integer NOT NULL,
);

CREATE TABLE colors (
    id integer NOT NULL,
    name character varying NOT NULL,
    hexcode character varying NOT NULL,
    created_at timestamp without time zone,
updated_at timestamp without time zone,
);

CREATE TABLE comments (
    id integer NOT NULL,
    commented_type character varying(30)    NOT NULL,
    commented_id integer   NOT NULL,
    author_id integer   NOT NULL,
    comments character varying(255),
    created_at timestamp without time zone   NOT NULL,
updated_at timestamp without time zone   NOT NULL,
);

CREATE TABLE cost_entries (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    work_package_id integer NOT NULL,
    cost_type_id integer NOT NULL,
    units double precision NOT NULL,
    spent_on date NOT NULL,
    created_at timestamp without time zone   NOT NULL,
    updated_at timestamp without time zone   NOT NULL,
    comments character varying NOT NULL,
    blocked boolean   NOT NULL,
    overridden_costs numeric(15,4),
    costs numeric(15,4),
    rate_id integer,
    tyear integer NOT NULL,
    tmonth integer NOT NULL,
tweek integer NOT NULL,
);

CREATE TABLE cost_queries (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer,
    name character varying NOT NULL,
    is_public boolean   NOT NULL,
    created_at timestamp without time zone   NOT NULL,
    updated_at timestamp without time zone   NOT NULL,
serialized character varying(2000) NOT NULL,
);

CREATE TABLE cost_types (
    id integer NOT NULL,
    name character varying NOT NULL,
    unit character varying NOT NULL,
    unit_plural character varying NOT NULL,
    "default" boolean   NOT NULL,
deleted_at timestamp without time zone,
);

CREATE TABLE custom_actions (
    id integer NOT NULL,
    name character varying,
    actions character varying(255),
    description character varying(255),
"position" integer,
);

CREATE TABLE custom_actions_projects (
    id integer NOT NULL,
    project_id bigint,
custom_action_id bigint,
);

CREATE TABLE custom_actions_roles (
    id integer NOT NULL,
    role_id bigint,
custom_action_id bigint,
);

CREATE TABLE custom_actions_statuses (
    id integer NOT NULL,
    status_id bigint,
custom_action_id bigint,
);

CREATE TABLE custom_actions_types (
    id integer NOT NULL,
    type_id bigint,
custom_action_id bigint,
);

CREATE TABLE custom_fields (
    id integer NOT NULL,
    type character varying(30)    NOT NULL,
    field_format character varying(30)    NOT NULL,
    regexp character varying   ,
    min_length integer   NOT NULL,
    max_length integer   NOT NULL,
    is_required boolean   NOT NULL,
    is_for_all boolean   NOT NULL,
    is_filter boolean   NOT NULL,
    "position" integer  ,
    searchable boolean  ,
    editable boolean  ,
    visible boolean   NOT NULL,
    multi_value boolean  ,
    "default_value" character varying(255),
    name character varying   ,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
content_right_to_left boolean,
);

CREATE TABLE custom_fields_new (
    id integer   NOT NULL,
    type character varying(30)    NOT NULL,
    field_format_int public.custom_fields_field_format_value NOT NULL,
    regexp character varying   ,
    min_length integer   NOT NULL,
    max_length integer   NOT NULL,
    is_required boolean   NOT NULL,
    is_for_all boolean   NOT NULL,
    is_filter boolean   NOT NULL,
    "position" integer  ,
    searchable boolean  ,
    editable boolean  ,
    visible boolean   NOT NULL,
    multi_value boolean  ,
    "default_value" character varying(255),
    name character varying   ,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
content_right_to_left boolean,
);

CREATE TABLE custom_fields_projects (
    custom_field_id integer   NOT NULL,
project_id integer   NOT NULL,
);

CREATE TABLE custom_fields_storage (
    id integer   NOT NULL,
    type character varying(30)    NOT NULL,
    field_format public.custom_fields_field_format_storage NOT NULL,
    regexp character varying   ,
    min_length integer   NOT NULL,
    max_length integer   NOT NULL,
    is_required boolean   NOT NULL,
    is_for_all boolean   NOT NULL,
    is_filter boolean   NOT NULL,
    "position" integer  ,
    searchable boolean  ,
    editable boolean  ,
    visible boolean   NOT NULL,
    multi_value boolean  ,
    "default_value" character varying(255),
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
content_right_to_left boolean,
);

CREATE TABLE custom_fields_types (
    custom_field_id integer   NOT NULL,
type_id integer   NOT NULL,
);

CREATE TABLE custom_options (
    id integer NOT NULL,
    custom_field_id integer,
    "position" integer,
    "default_value" boolean,
    "value" character varying(255),
    created_at timestamp without time zone,
updated_at timestamp without time zone,
);

CREATE TABLE custom_styles (
    id integer NOT NULL,
    logo character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    favicon character varying,
    touch_icon character varying,
    theme character varying   ,
theme_logo character varying,
);

CREATE TABLE custom_values (
    id integer NOT NULL,
    customized_type character varying(30)    NOT NULL,
    customized_id integer   NOT NULL,
    custom_field_id integer   NOT NULL,
"value" character varying(255),
);

CREATE TABLE customizable_journals (
    id integer NOT NULL,
    journal_id integer NOT NULL,
    custom_field_id integer NOT NULL,
"value" character varying(255),
);

CREATE TABLE delayed_job_statuses (
    id bigint NOT NULL,
    reference_type character varying,
    reference_id bigint,
    message character varying,
    created_at timestamp(6) without time zone   NOT NULL,
    updated_at timestamp(6) without time zone   NOT NULL,
    status public.delayed_job_status  ,
    user_id bigint,
    job_id character varying,
payload jsonb,
);

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer  ,
    attempts integer  ,
    handler character varying(255),
    last_error character varying(255),
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    queue character varying,
cron character varying,
);

CREATE TABLE design_colors (
    id integer NOT NULL,
    variable character varying,
    hexcode character varying,
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
UNIQUE(variable),
);

CREATE TABLE document_journals (
    id integer NOT NULL,
    project_id integer   NOT NULL,
    category_id integer   NOT NULL,
    title character varying(60)    NOT NULL,
description character varying(255),
);

CREATE TABLE documents (
    id integer NOT NULL,
    project_id integer   NOT NULL,
    category_id integer   NOT NULL,
    title character varying(60)    NOT NULL,
    description character varying(255),
    created_at timestamp without time zone,
updated_at timestamp without time zone,
);

CREATE TABLE done_statuses_for_project (
    project_id integer,
status_id integer,
);

CREATE TABLE enabled_modules (
    id integer NOT NULL,
    project_id integer,
name character varying NOT NULL,
UNIQUE(name,project_id),
);

CREATE TABLE enterprise_tokens (
    id integer NOT NULL,
    encoded_token character varying(255),
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
);

CREATE TABLE enumerations (
    id integer NOT NULL,
    name character varying(30)    NOT NULL,
    "position" integer  ,
    is_default boolean   NOT NULL,
    type character varying,
    active boolean   NOT NULL,
    project_id integer,
    parent_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
color_id integer,
UNIQUE(name,type,project_id),
);

CREATE TABLE export_card_configurations (
    id integer NOT NULL,
    name character varying,
    per_page integer,
    page_size character varying,
    orientation character varying,
    rows character varying(255),
    active boolean  ,
description character varying(255),
);

CREATE TABLE exports (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
type character varying,
);

CREATE TABLE forums (
    id integer NOT NULL,
    project_id integer NOT NULL,
    name character varying    NOT NULL,
    description character varying,
    "position" integer  ,
    topics_count integer   NOT NULL,
    messages_count integer   NOT NULL,
last_message_id integer,
);

CREATE TABLE github_check_runs (
    id bigint NOT NULL,
    github_pull_request_id bigint NOT NULL,
    github_id bigint NOT NULL,
    github_html_url character varying NOT NULL,
    app_id bigint NOT NULL,
    github_app_owner_avatar_url character varying NOT NULL,
    status character varying NOT NULL,
    name character varying NOT NULL,
    conclusion character varying,
    output_title character varying,
    output_summary character varying,
    details_url character varying,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
updated_at timestamp(6) without time zone NOT NULL,
);

CREATE TABLE github_pull_requests (
    id bigint NOT NULL,
    github_user_id bigint,
    merged_by_id bigint,
    github_id bigint,
    number integer NOT NULL,
    github_html_url character varying NOT NULL,
    state character varying NOT NULL,
    repository character varying NOT NULL,
    github_updated_at timestamp without time zone,
    title character varying,
    body character varying(255),
    draft boolean,
    merged boolean,
    merged_at timestamp without time zone,
    comments_count integer,
    review_comments_count integer,
    additions_count integer,
    deletions_count integer,
    changed_files_count integer,
    labels json,
    created_at timestamp(6) without time zone NOT NULL,
updated_at timestamp(6) without time zone NOT NULL,
);

CREATE TABLE github_pull_requests_work_packages (
    github_pull_request_id bigint NOT NULL,
work_package_id bigint NOT NULL,
);

CREATE TABLE github_users (
    id bigint NOT NULL,
    github_id bigint NOT NULL,
    github_login character varying NOT NULL,
    github_html_url character varying NOT NULL,
    github_avatar_url character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
updated_at timestamp(6) without time zone NOT NULL,
);

CREATE TABLE grid_widgets (
    id bigint NOT NULL,
    start_row integer NOT NULL,
    end_row integer NOT NULL,
    start_column integer NOT NULL,
    end_column integer NOT NULL,
    identifier character varying,
    options character varying(255),
grid_id bigint,
);

CREATE TABLE grids (
    id bigint NOT NULL,
    row_count integer NOT NULL,
    column_count integer NOT NULL,
    type character varying,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id bigint,
    name character varying(255),
options character varying(255),
);

CREATE TABLE grids_storage (
    id bigint   NOT NULL,
    row_count integer NOT NULL,
    column_count integer NOT NULL,
    type public.grids_type_storage,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id bigint,
    name character varying(255),
options character varying(255),
);

CREATE TABLE group_users (
    group_id integer NOT NULL,
    user_id integer NOT NULL,
id bigint NOT NULL,
UNIQUE(group_id,user_id),
UNIQUE(user_id,group_id),
);

CREATE TABLE ifc_models (
    id bigint NOT NULL,
    title character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id bigint,
    uploader_id bigint,
is_default boolean   NOT NULL,
);

CREATE TABLE journals (
    id integer NOT NULL,
    journable_type character varying,
    journable_id integer,
    user_id integer   NOT NULL,
    notes character varying(255),
    created_at timestamp without time zone NOT NULL,
    version integer   NOT NULL,
    activity_type character varying,
    updated_at timestamp without time zone  ,
    data_type character varying,
data_id bigint,
UNIQUE(version,journable_id,journable_type),
UNIQUE(data_id,data_type),
UNIQUE(journable_type,journable_id,version),
);

CREATE TABLE labor_budget_items (
    id integer NOT NULL,
    budget_id integer NOT NULL,
    hours double precision NOT NULL,
    user_id integer,
    comments character varying    NOT NULL,
amount numeric(15,4),
);

CREATE TABLE ldap_groups_memberships (
    id integer NOT NULL,
    user_id integer,
    group_id integer,
    created_at timestamp without time zone   NOT NULL,
updated_at timestamp without time zone   NOT NULL,
);

CREATE TABLE ldap_groups_synchronized_filters (
    id bigint NOT NULL,
    name character varying,
    group_name_attribute character varying,
    filter_string character varying,
    auth_source_id bigint,
    created_at timestamp(6) without time zone   NOT NULL,
    updated_at timestamp(6) without time zone   NOT NULL,
    base_dn character varying(255),
sync_users boolean   NOT NULL,
);

CREATE TABLE ldap_groups_synchronized_groups (
    id integer NOT NULL,
    group_id integer,
    auth_source_id integer,
    created_at timestamp without time zone   NOT NULL,
    updated_at timestamp without time zone   NOT NULL,
    dn character varying(255),
    users_count integer   NOT NULL,
    filter_id bigint,
sync_users boolean   NOT NULL,
);

CREATE TABLE material_budget_items (
    id integer NOT NULL,
    budget_id integer NOT NULL,
    units double precision NOT NULL,
    cost_type_id integer,
    comments character varying    NOT NULL,
amount numeric(15,4),
);

CREATE TABLE meeting_content_journals (
    id integer NOT NULL,
    meeting_id integer,
    author_id integer,
    character varying(255) text,
locked boolean,
);

CREATE TABLE meeting_contents (
    id integer NOT NULL,
    type character varying,
    meeting_id integer,
    author_id integer,
    character varying(255) text,
    lock_version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
locked boolean,
);

CREATE TABLE meeting_contents_storage (
    id integer   NOT NULL,
    type public.meeting_contents_type_storage,
    meeting_id integer,
    author_id integer,
    character varying(255) text,
    lock_version integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
locked boolean,
);

CREATE TABLE meeting_journals (
    id integer NOT NULL,
    title character varying,
    author_id integer,
    project_id integer,
    location character varying,
    start_time timestamp without time zone,
duration double precision,
);

CREATE TABLE meeting_participants (
    id integer NOT NULL,
    user_id integer,
    meeting_id integer,
    email character varying,
    name character varying,
    invited boolean,
    attended boolean,
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
);

CREATE TABLE meetings (
    id integer NOT NULL,
    title character varying,
    author_id integer,
    project_id integer,
    location character varying,
    start_time timestamp without time zone,
    duration double precision,
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
);

CREATE TABLE member_roles (
    id integer NOT NULL,
    member_id integer NOT NULL,
    role_id integer NOT NULL,
inherited_from integer,
UNIQUE(member_id,role_id,inherited_from),
);

CREATE TABLE members (
    id integer NOT NULL,
    user_id integer   NOT NULL,
    project_id integer,
    created_at timestamp without time zone  ,
updated_at timestamp without time zone   NOT NULL,
UNIQUE(user_id,project_id),
);

CREATE TABLE menu_items (
    id integer NOT NULL,
    name character varying,
    title character varying,
    parent_id integer,
    options character varying(255),
    navigatable_id integer,
type character varying,
UNIQUE(title,navigatable_id,type),
UNIQUE(name,navigatable_id,parent_id),
);

CREATE TABLE message_journals (
    id integer NOT NULL,
    forum_id integer NOT NULL,
    parent_id integer,
    subject character varying    NOT NULL,
    content character varying(255),
    author_id integer,
    locked boolean  ,
sticky integer,
);

CREATE TABLE messages (
    id integer NOT NULL,
    forum_id integer NOT NULL,
    parent_id integer,
    subject character varying    NOT NULL,
    content character varying(255),
    author_id integer,
    replies_count integer   NOT NULL,
    last_reply_id integer,
    created_at timestamp without time zone   NOT NULL,
    updated_at timestamp without time zone   NOT NULL,
    locked boolean  ,
    sticky integer  ,
sticked_on timestamp without time zone,
);

CREATE TABLE news (
    id integer NOT NULL,
    project_id integer,
    title character varying(60)    NOT NULL,
    summary character varying   ,
    description character varying(255),
    author_id integer   NOT NULL,
    created_at timestamp without time zone,
    comments_count integer   NOT NULL,
updated_at timestamp without time zone,
);

CREATE TABLE news_journals (
    id integer NOT NULL,
    project_id integer,
    title character varying(60)    NOT NULL,
    summary character varying   ,
    description character varying(255),
    author_id integer   NOT NULL,
comments_count integer   NOT NULL,
);

CREATE TABLE notification_settings (
    id bigint NOT NULL,
    project_id bigint,
    user_id bigint NOT NULL,
    channel smallint,
    watched boolean  ,
    involved boolean  ,
    mentioned boolean  ,
    "all" boolean  ,
    created_at timestamp(6) without time zone   NOT NULL,
    updated_at timestamp(6) without time zone   NOT NULL,
    work_package_commented boolean  ,
    work_package_created boolean  ,
    work_package_processed boolean  ,
    work_package_prioritized boolean  ,
work_package_scheduled boolean,
UNIQUE(channel,project_id,user_id),
);

CREATE TABLE notifications (
    id bigint NOT NULL,
    subject character varying(255),
    read_ian boolean  ,
    read_mail boolean  ,
    reason_ian smallint,
    recipient_id bigint NOT NULL,
    actor_id bigint,
    resource_type character varying NOT NULL,
    resource_id bigint NOT NULL,
    project_id bigint,
    journal_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    read_mail_digest boolean  ,
    reason_mail smallint,
reason_mail_digest smallint,
);

CREATE TABLE oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id bigint NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying,
    code_challenge character varying,
code_challenge_method character varying,
);

CREATE TABLE oauth_access_tokens (
    id bigint NOT NULL,
    resource_owner_id bigint,
    application_id bigint,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
previous_refresh_token character varying    NOT NULL,
);

CREATE TABLE oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    owner_type character varying,
    owner_id integer,
    client_credentials_user_id integer,
    redirect_uri character varying(255) NOT NULL,
    scopes character varying    NOT NULL,
    confidential boolean   NOT NULL,
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
);

CREATE TABLE ordered_work_packages (
    id bigint NOT NULL,
    "position" integer NOT NULL,
    query_id integer,
work_package_id integer,
);

CREATE TABLE plaintext_tokens (
    id integer NOT NULL,
    user_id integer   NOT NULL,
    action character varying(30)    NOT NULL,
    "value" character varying(40)    NOT NULL,
created_on timestamp without time zone NOT NULL,
);

CREATE TABLE project_associations (
    id integer NOT NULL,
    project_a_id integer,
    project_b_id integer,
    description character varying(255),
    created_at timestamp without time zone,
updated_at timestamp without time zone,
);

CREATE TABLE project_statuses (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    explanation character varying(255),
    code integer,
    created_at timestamp(6) without time zone NOT NULL,
updated_at timestamp(6) without time zone NOT NULL,
);

CREATE TABLE projects (
    id integer NOT NULL,
    name character varying    NOT NULL,
    description character varying(255),
    public boolean   NOT NULL,
    parent_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    identifier character varying,
    lft integer,
    rgt integer,
    active boolean   NOT NULL,
templated boolean   NOT NULL,
UNIQUE(identifier),
);

CREATE TABLE projects_types (
    project_id integer   NOT NULL,
type_id integer   NOT NULL,
);

CREATE TABLE queries (
    id integer NOT NULL,
    project_id integer,
    name character varying    NOT NULL,
    filters character varying(255),
    user_id integer   NOT NULL,
    is_public boolean   NOT NULL,
    column_names character varying(255),
    sort_criteria character varying(255),
    group_by character varying,
    display_sums boolean   NOT NULL,
    timeline_visible boolean  ,
    show_hierarchies boolean  ,
    timeline_zoom_level integer  ,
    timeline_labels character varying(255),
    highlighting_mode character varying(255),
    highlighted_attributes character varying(255),
    hidden boolean  ,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
display_representation character varying(255),
);

CREATE TABLE rates (
    id integer NOT NULL,
    valid_from date NOT NULL,
    rate numeric(15,4) NOT NULL,
    type character varying NOT NULL,
    project_id integer,
    user_id integer,
cost_type_id integer,
);

CREATE TABLE rates_new (
    id integer   NOT NULL,
    valid_from date NOT NULL,
    rate numeric(15,4) NOT NULL,
    type_int public.rates_type_value NOT NULL,
    project_id integer,
    user_id integer,
cost_type_id integer,
);

CREATE TABLE rates_storage (
    id integer   NOT NULL,
    valid_from date NOT NULL,
    rate numeric(15,4) NOT NULL,
    type public.rates_type_storage NOT NULL,
    project_id integer,
    user_id integer,
cost_type_id integer,
);

CREATE TABLE recaptcha_entries (
    id integer NOT NULL,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
version integer NOT NULL,
);

CREATE TABLE relations (
    id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL,
    delay integer,
    description character varying(255),
    hierarchy integer   NOT NULL,
    relates integer   NOT NULL,
    duplicates integer   NOT NULL,
    blocks integer   NOT NULL,
    follows integer   NOT NULL,
    includes integer   NOT NULL,
    requires integer   NOT NULL,
count integer   NOT NULL,
UNIQUE(from_id,to_id,hierarchy,relates,duplicates,blocks,follows,includes,requires),
);

CREATE TABLE repositories (
    id integer NOT NULL,
    project_id integer   NOT NULL,
    url character varying    NOT NULL,
    login character varying(60)   ,
    password character varying   ,
    root_url character varying   ,
    type character varying,
    path_encoding character varying(64),
    log_encoding character varying(64),
    scm_type character varying NOT NULL,
    required_storage_bytes bigint   NOT NULL,
storage_updated_at timestamp without time zone,
UNIQUE(project_id),
);

CREATE TABLE role_permissions (
    id integer NOT NULL,
    permission character varying,
    role_id integer,
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
);

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(30)    NOT NULL,
    "position" integer  ,
    assignable boolean  ,
    builtin integer   NOT NULL,
    type character varying(30)   ,
    created_at timestamp without time zone  ,
updated_at timestamp without time zone,
UNIQUE(name),
);

CREATE TABLE roles_new (
    id integer   NOT NULL,
    name character varying(30)    NOT NULL,
    "position" integer  ,
    assignable boolean  ,
    builtin integer   NOT NULL,
    type_int public.roles_type_value,
    created_at timestamp without time zone  ,
updated_at timestamp without time zone,
);

CREATE TABLE roles_storage (
    id integer   NOT NULL,
    name character varying(30)    NOT NULL,
    "position" integer  ,
    assignable boolean  ,
    builtin integer   NOT NULL,
    type public.roles_type_storage,
    created_at timestamp without time zone  ,
updated_at timestamp without time zone,
);

CREATE TABLE schema_migrations (
version character varying NOT NULL,
);

CREATE TABLE settings (
    id integer NOT NULL,
    name character varying    NOT NULL,
    "value" character varying(255),
updated_at timestamp without time zone,
UNIQUE(name),
);

CREATE TABLE settings_new (
    id integer   NOT NULL,
    name_int public.settings_name_value NOT NULL,
    "value" character varying(255),
updated_at timestamp without time zone,
);

CREATE TABLE settings_storage (
    id integer   NOT NULL,
    name public.settings_name_storage NOT NULL,
    "value" character varying(255),
updated_at timestamp without time zone,
);

CREATE TABLE statuses (
    id integer NOT NULL,
    name character varying(30)    NOT NULL,
    is_closed boolean   NOT NULL,
    is_default boolean   NOT NULL,
    "position" integer  ,
    default_done_ratio integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    color_id integer,
is_readonly boolean,
UNIQUE(name),
);

CREATE TABLE time_entries (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    work_package_id integer,
    hours double precision NOT NULL,
    comments character varying,
    activity_id integer NOT NULL,
    spent_on date NOT NULL,
    tyear integer NOT NULL,
    tmonth integer NOT NULL,
    tweek integer NOT NULL,
    created_at timestamp without time zone   NOT NULL,
    updated_at timestamp without time zone   NOT NULL,
    overridden_costs numeric(15,4),
    costs numeric(15,4),
rate_id integer,
);

CREATE TABLE time_entry_activities_projects (
    id bigint NOT NULL,
    activity_id bigint NOT NULL,
    project_id bigint NOT NULL,
active boolean,
);

CREATE TABLE time_entry_journals (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    work_package_id integer,
    hours double precision NOT NULL,
    comments character varying,
    activity_id integer NOT NULL,
    spent_on date NOT NULL,
    tyear integer NOT NULL,
    tmonth integer NOT NULL,
    tweek integer NOT NULL,
    overridden_costs numeric(15,2),
    costs numeric(15,2),
rate_id integer,
);

CREATE TABLE tokens (
    id integer NOT NULL,
    user_id bigint,
    type character varying,
    "value" character varying(128)    NOT NULL,
    created_at timestamp without time zone   NOT NULL,
expires_on timestamp without time zone,
UNIQUE(value),
);

CREATE TABLE two_factor_authentication_devices (
    id integer NOT NULL,
    type character varying,
    "default" boolean   NOT NULL,
    active boolean   NOT NULL,
    channel character varying NOT NULL,
    phone_number character varying,
    identifier character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_used_at integer,
    otp_secret character varying(255),
user_id integer,
);

CREATE TABLE types (
    id integer NOT NULL,
    name character varying    NOT NULL,
    "position" integer  ,
    is_in_roadmap boolean   NOT NULL,
    is_milestone boolean   NOT NULL,
    is_default boolean   NOT NULL,
    color_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_standard boolean   NOT NULL,
    attribute_groups character varying(255),
description character varying(255),
UNIQUE(name),
);

CREATE TABLE user_passwords (
    id integer NOT NULL,
    user_id integer NOT NULL,
    hashed_password character varying(128) NOT NULL,
    salt character varying(64),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
type character varying NOT NULL,
);

CREATE TABLE user_preferences (
    id integer NOT NULL,
    user_id integer   NOT NULL,
    others character varying(255),
    hide_mail boolean  ,
time_zone character varying,
);

CREATE TABLE users (
    id integer NOT NULL,
    login character varying(256)    NOT NULL,
    firstname character varying    NOT NULL,
    lastname character varying    NOT NULL,
    mail character varying    NOT NULL,
    admin boolean   NOT NULL,
    status integer   NOT NULL,
    last_login_on timestamp without time zone,
    "language" character varying(5)   ,
    auth_source_id integer,
    created_at timestamp without time zone  ,
    updated_at timestamp without time zone  ,
    type character varying,
    identity_url character varying,
    mail_notification character varying    NOT NULL,
    first_login boolean   NOT NULL,
    force_password_change boolean  ,
    failed_login_count integer  ,
    last_failed_login_on timestamp without time zone,
consented_at timestamp without time zone,
);

CREATE TABLE version_settings (
    id integer NOT NULL,
    project_id integer,
    version_id integer,
    display integer,
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
);

CREATE TABLE versions (
    id integer NOT NULL,
    project_id integer   NOT NULL,
    name character varying    NOT NULL,
    description character varying   ,
    effective_date date,
    created_at timestamp without time zone  ,
    updated_at timestamp without time zone  ,
    wiki_page_title character varying,
    status character varying   ,
    sharing character varying    NOT NULL,
start_date date,
UNIQUE(name,project_id),
);

CREATE TABLE versions_storage (
    id integer   NOT NULL,
    project_id integer   NOT NULL,
    name character varying    NOT NULL,
    description character varying   ,
    effective_date date,
    created_at timestamp without time zone  ,
    updated_at timestamp without time zone  ,
    wiki_page_title character varying,
    status public.versions_status_storage,
    sharing character varying    NOT NULL,
start_date date,
);

CREATE TABLE watchers (
    id integer NOT NULL,
    watchable_type character varying    NOT NULL,
    watchable_id integer   NOT NULL,
user_id integer,
UNIQUE(user_id,watchable_type,watchable_id),
);

CREATE TABLE watchers_new (
    id integer   NOT NULL,
    watchable_type_int public.watchers_watchable_type_value NOT NULL,
    watchable_id integer   NOT NULL,
user_id integer,
);

CREATE TABLE watchers_storage (
    id integer   NOT NULL,
    watchable_type public.watchers_watchable_type_storage NOT NULL,
    watchable_id integer   NOT NULL,
user_id integer,
);

CREATE TABLE webhooks_events (
    id integer NOT NULL,
    name character varying,
webhooks_webhook_id integer,
);

CREATE TABLE webhooks_logs (
    id integer NOT NULL,
    webhooks_webhook_id integer,
    event_name character varying,
    url character varying,
    request_headers character varying(255),
    request_body character varying(255),
    response_code integer,
    response_headers character varying(255),
    response_body character varying(255),
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
);

CREATE TABLE webhooks_projects (
    id integer NOT NULL,
    project_id integer,
webhooks_webhook_id integer,
);

CREATE TABLE webhooks_webhooks (
    id integer NOT NULL,
    name character varying,
    url character varying(255),
    description character varying(255) NOT NULL,
    secret character varying,
    enabled boolean NOT NULL,
    all_projects boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
);

CREATE TABLE wiki_content_journals (
    id integer NOT NULL,
    page_id integer NOT NULL,
    author_id integer,
character varying(255) text,
);

CREATE TABLE wiki_contents (
    id integer NOT NULL,
    page_id integer NOT NULL,
    author_id integer,
    character varying(255) text,
    updated_at timestamp without time zone   NOT NULL,
lock_version integer NOT NULL,
UNIQUE(page_id),
);

CREATE TABLE wiki_pages (
    id integer NOT NULL,
    wiki_id integer NOT NULL,
    title character varying NOT NULL,
    created_at timestamp without time zone   NOT NULL,
    protected boolean   NOT NULL,
    parent_id integer,
    slug character varying NOT NULL,
updated_at timestamp without time zone NOT NULL,
UNIQUE(wiki_id,slug),
);

CREATE TABLE wiki_redirects (
    id integer NOT NULL,
    wiki_id integer NOT NULL,
    title character varying,
    redirects_to character varying,
created_at timestamp without time zone   NOT NULL,
);

CREATE TABLE wikis (
    id integer NOT NULL,
    project_id integer NOT NULL,
    start_page character varying NOT NULL,
    status integer   NOT NULL,
    created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
UNIQUE(project_id),
);

CREATE TABLE work_package_journals (
    id integer NOT NULL,
    type_id integer   NOT NULL,
    project_id integer   NOT NULL,
    subject character varying    NOT NULL,
    description character varying(255),
    due_date date,
    category_id integer,
    status_id integer   NOT NULL,
    assigned_to_id integer,
    priority_id integer   NOT NULL,
    version_id integer,
    author_id integer   NOT NULL,
    done_ratio integer   NOT NULL,
    estimated_hours double precision,
    start_date date,
    parent_id integer,
    responsible_id integer,
    budget_id integer,
    story_points integer,
    remaining_hours double precision,
    derived_estimated_hours double precision,
schedule_manually boolean,
);

CREATE TABLE work_packages (
    id integer NOT NULL,
    type_id integer   NOT NULL,
    project_id integer   NOT NULL,
    subject character varying    NOT NULL,
    description character varying(255),
    due_date date,
    category_id integer,
    status_id integer   NOT NULL,
    assigned_to_id integer,
    priority_id integer  ,
    version_id integer,
    author_id integer   NOT NULL,
    lock_version integer   NOT NULL,
    done_ratio integer   NOT NULL,
    estimated_hours double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    start_date date,
    responsible_id integer,
    budget_id integer,
    "position" integer,
    story_points integer,
    remaining_hours double precision,
    derived_estimated_hours double precision,
schedule_manually boolean,
);

CREATE TABLE workflows (
    id integer NOT NULL,
    type_id integer   NOT NULL,
    old_status_id integer   NOT NULL,
    new_status_id integer   NOT NULL,
    role_id integer   NOT NULL,
    assignee boolean   NOT NULL,
author boolean   NOT NULL,
);

-- Original Query
SELECT roles.id AS t0_r0, roles.name AS t0_r1, roles.position AS t0_r2, roles.assignable AS t0_r3, roles.builtin AS t0_r4, roles.type AS t0_r5, roles.created_at AS t0_r6, roles.updated_at AS t0_r7, role_permissions.id AS t1_r0, role_permissions.permission AS t1_r1, role_permissions.role_id AS t1_r2, role_permissions.created_at AS t1_r3, role_permissions.updated_at AS t1_r4 FROM roles LEFT OUTER JOIN role_permissions ON role_permissions.role_id = roles.id WHERE roles.id IN (SELECT roles.id FROM users LEFT OUTER JOIN members ON users.id = members.user_id AND members.project_id = 1224 LEFT OUTER JOIN member_roles ON members.id = member_roles.member_id LEFT OUTER JOIN roles ON roles.id = member_roles.role_id WHERE users.id = 3657);
-- Rewritten Queries
SELECT roles.id AS t0_r0, roles.name AS t0_r1, roles.position AS t0_r2, roles.assignable AS t0_r3, roles.builtin AS t0_r4, roles.type AS t0_r5, roles.created_at AS t0_r6, roles.updated_at AS t0_r7, role_permissions.id AS t1_r0, role_permissions.permission AS t1_r1, role_permissions.role_id AS t1_r2, role_permissions.created_at AS t1_r3, role_permissions.updated_at AS t1_r4 FROM roles LEFT OUTER JOIN role_permissions ON role_permissions.role_id = roles.id WHERE roles.id IN (SELECT roles.id FROM users LEFT OUTER JOIN members ON users.id = members.user_id AND members.project_id = 1224 LEFT OUTER JOIN member_roles ON members.id = member_roles.member_id LEFT OUTER JOIN roles ON roles.id = member_roles.role_id WHERE users.id = 3657) LIMIT 1;
