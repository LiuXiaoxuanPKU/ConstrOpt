CREATE TABLE ahoy_events (
    id bigint NOT NULL,
    name character varying,
    properties jsonb,
    "time" timestamp without time zone,
    user_id bigint,
    visit_id bigint
);

CREATE TABLE ahoy_messages (
    id bigint NOT NULL,
    clicked_at timestamp without time zone,
    content character varying(255),
    feedback_message_id bigint,
    mailer character varying,
    sent_at timestamp without time zone,
    subject character varying(255),
    "to" character varying(255),
    token character varying,
    user_id bigint,
    user_type character varying,
    utm_campaign character varying,
    utm_content character varying,
    utm_medium character varying,
    utm_source character varying,
    utm_term character varying
);

CREATE TABLE ahoy_visits (
    id bigint NOT NULL,
    started_at timestamp without time zone,
    user_id bigint,
    visit_token character varying,
    visitor_token character varying
);

CREATE TABLE announcements (
    id bigint NOT NULL,
    banner_style character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE api_secrets (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    description character varying NOT NULL,
    secret character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    "value" character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE articles (
    id bigint NOT NULL,
    any_comments_hidden boolean  ,
    approved boolean  ,
    archived boolean  ,
    body_html character varying(255),
    body_markdown character varying(255),
    boost_states jsonb   NOT NULL,
    cached_organization character varying(255),
    cached_tag_list character varying,
    cached_user character varying(255),
    cached_user_name character varying,
    cached_user_username character varying,
    canonical_url character varying,
    co_author_ids bigint[]  ,
    collection_id bigint,
    comment_score integer  ,
    comment_template character varying,
    comments_count integer   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    crossposted_at timestamp without time zone,
    description character varying,
    edited_at timestamp without time zone,
    email_digest_eligible boolean  ,
    experience_level_rating double precision  ,
    experience_level_rating_distribution double precision  ,
    featured boolean  ,
    featured_number integer,
    feed_source_url character varying,
    hotness_score integer  ,
    last_experience_level_rating_at timestamp without time zone,
    main_image character varying,
    main_image_background_hex_color character varying   ,
    nth_published_by_author integer  ,
    organic_page_views_count integer  ,
    organic_page_views_past_month_count integer  ,
    organic_page_views_past_week_count integer  ,
    organization_id bigint,
    originally_published_at timestamp without time zone,
    page_views_count integer  ,
    password character varying,
    path character varying,
    positive_reactions_count integer   NOT NULL,
    previous_positive_reactions_count integer  ,
    previous_public_reactions_count integer   NOT NULL,
    processed_html character varying(255),
    public_reactions_count integer   NOT NULL,
    published boolean  ,
    published_at timestamp without time zone,
    published_from_feed boolean  ,
    rating_votes_count integer   NOT NULL,
    reactions_count integer   NOT NULL,
    reading_list_document tsvector,
    reading_time integer  ,
    receive_notifications boolean  ,
    score integer  ,
    search_optimized_description_replacement character varying,
    search_optimized_title_preamble character varying,
    show_comments boolean  ,
    slug character varying(255),
    social_image character varying,
    spaminess_rating integer  ,
    title character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint,
    user_subscriptions_count integer   NOT NULL,
    video character varying,
    video_closed_caption_track_url character varying,
    video_code character varying,
    video_duration_in_seconds double precision  ,
    video_source_url character varying,
    video_state character varying,
    video_thumbnail_url character varying
);

CREATE TABLE articles_storage (
    id bigint   NOT NULL,
    any_comments_hidden boolean  ,
    approved boolean  ,
    archived boolean  ,
    body_html character varying(255),
    body_markdown character varying(255),
    boost_states jsonb   NOT NULL,
    cached_organization character varying(255),
    cached_tag_list character varying,
    cached_user character varying(255),
    cached_user_name character varying,
    cached_user_username character varying,
    canonical_url character varying,
    co_author_ids bigint[]  ,
    collection_id bigint,
    comment_score integer  ,
    comment_template character varying,
    comments_count integer   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    crossposted_at timestamp without time zone,
    description character varying,
    edited_at timestamp without time zone,
    email_digest_eligible boolean  ,
    experience_level_rating double precision  ,
    experience_level_rating_distribution double precision  ,
    featured boolean  ,
    featured_number integer,
    feed_source_url character varying,
    hotness_score integer  ,
    last_comment_at timestamp without time zone,
    last_experience_level_rating_at timestamp without time zone,
    main_image character varying,
    main_image_background_hex_color character varying   ,
    nth_published_by_author integer  ,
    organic_page_views_count integer  ,
    organic_page_views_past_month_count integer  ,
    organic_page_views_past_week_count integer  ,
    organization_id bigint,
    originally_published_at timestamp without time zone,
    page_views_count integer  ,
    password character varying,
    path character varying,
    positive_reactions_count integer   NOT NULL,
    previous_positive_reactions_count integer  ,
    previous_public_reactions_count integer   NOT NULL,
    processed_html character varying(255),
    public_reactions_count integer   NOT NULL,
    published boolean  ,
    published_at timestamp without time zone,
    published_from_feed boolean  ,
    rating_votes_count integer   NOT NULL,
    reactions_count integer   NOT NULL,
    reading_list_document tsvector,
    reading_time integer  ,
    receive_notifications boolean  ,
    score integer  ,
    search_optimized_description_replacement character varying,
    search_optimized_title_preamble character varying,
    show_comments boolean  ,
    slug character varying(255),
    social_image character varying,
    spaminess_rating integer  ,
    title character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint,
    user_subscriptions_count integer   NOT NULL,
    video character varying,
    video_closed_caption_track_url character varying,
    video_code character varying,
    video_duration_in_seconds double precision  ,
    video_source_url character varying,
    video_state public.articles_video_state_storage,
    video_thumbnail_url character varying
);

CREATE TABLE audit_logs (
    id bigint NOT NULL,
    category character varying,
    created_at timestamp without time zone NOT NULL,
    data jsonb   NOT NULL,
    roles character varying[],
    slug character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE badge_achievements (
    id bigint NOT NULL,
    badge_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    rewarder_id bigint,
    rewarding_context_message character varying(255),
    rewarding_context_message_markdown character varying(255),
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE badges (
    id bigint NOT NULL,
    badge_image character varying,
    created_at timestamp without time zone NOT NULL,
    credits_awarded integer   NOT NULL,
    description character varying NOT NULL,
    slug character varying NOT NULL,
    title character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE banished_users (
    id bigint NOT NULL,
    banished_by_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    username character varying
);

CREATE TABLE blazer_audits (
    id bigint NOT NULL,
    created_at timestamp without time zone,
    data_source character varying,
    query_id bigint,
    statement character varying(255),
    user_id bigint
);

CREATE TABLE blazer_checks (
    id bigint NOT NULL,
    check_type character varying,
    created_at timestamp without time zone NOT NULL,
    creator_id bigint,
    emails character varying(255),
    last_run_at timestamp without time zone,
    message character varying(255),
    query_id bigint,
    schedule character varying,
    slack_channels character varying(255),
    state character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE blazer_dashboard_queries (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    dashboard_id bigint,
    "position" integer,
    query_id bigint,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE blazer_dashboards (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    creator_id bigint,
    name character varying(255),
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE blazer_queries (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    creator_id bigint,
    data_source character varying,
    description character varying(255),
    name character varying,
    statement character varying(255),
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE broadcasts (
    id bigint NOT NULL,
    active boolean  ,
    active_status_updated_at timestamp without time zone,
    banner_style character varying,
    body_markdown character varying(255),
    broadcastable_id bigint,
    broadcastable_type character varying,
    created_at timestamp without time zone,
    processed_html character varying(255),
    title character varying,
    type_of character varying,
    updated_at timestamp without time zone
);

CREATE TABLE broadcasts_new (
    id bigint   NOT NULL,
    active boolean  ,
    active_status_updated_at timestamp without time zone,
    banner_style character varying,
    body_markdown character varying(255),
    broadcastable_id bigint,
    broadcastable_type character varying,
    created_at timestamp without time zone,
    processed_html character varying(255),
    title character varying,
    type_of_int public.broadcasts_type_of_value,
    updated_at timestamp without time zone
);

CREATE TABLE broadcasts_storage (
    id bigint   NOT NULL,
    active boolean  ,
    active_status_updated_at timestamp without time zone,
    banner_style public.broadcasts_banner_style_storage,
    body_markdown character varying(255),
    broadcastable_id bigint,
    broadcastable_type character varying,
    created_at timestamp without time zone,
    processed_html character varying(255),
    title character varying,
    type_of public.broadcasts_type_of_storage,
    updated_at timestamp without time zone
);

CREATE TABLE chat_channel_memberships (
    id bigint NOT NULL,
    chat_channel_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    has_unopened_messages boolean  ,
    last_opened_at timestamp without time zone,
    role character varying   ,
    show_global_badge_notification boolean  ,
    status character varying   ,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE chat_channel_memberships_new (
    id bigint   NOT NULL,
    chat_channel_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    has_unopened_messages boolean  ,
    last_opened_at timestamp without time zone,
    role character varying   ,
    show_global_badge_notification boolean  ,
    status_int public.chat_channel_memberships_status_value,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE chat_channel_memberships_storage (
    id bigint   NOT NULL,
    chat_channel_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    has_unopened_messages boolean  ,
    last_opened_at timestamp without time zone,
    role public.chat_channel_memberships_role_storage,
    show_global_badge_notification boolean  ,
    status public.chat_channel_memberships_status_storage,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE chat_channels (
    id bigint NOT NULL,
    channel_name character varying,
    channel_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    description character varying,
    discoverable boolean  ,
    last_message_at timestamp without time zone,
    slug character varying,
    status character varying   ,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE chat_channels_storage (
    id bigint   NOT NULL,
    channel_name character varying,
    channel_type public.chat_channels_channel_type_storage NOT NULL,
    created_at timestamp without time zone NOT NULL,
    description character varying,
    discoverable boolean  ,
    last_message_at timestamp without time zone,
    slug character varying,
    status public.chat_channels_status_storage,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE classified_listing_categories (
    id bigint NOT NULL,
    cost integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    name character varying NOT NULL,
    rules character varying NOT NULL,
    slug character varying NOT NULL,
    social_preview_color character varying,
    social_preview_description character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE classified_listings (
    id bigint NOT NULL,
    body_markdown character varying(255),
    bumped_at timestamp without time zone,
    cached_tag_list character varying,
    classified_listing_category_id bigint,
    contact_via_connect boolean  ,
    created_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone,
    location character varying,
    organization_id bigint,
    originally_published_at timestamp without time zone,
    processed_html character varying(255),
    published boolean,
    slug character varying,
    title character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE collections (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    description character varying,
    main_image character varying,
    organization_id bigint,
    published boolean  ,
    slug character varying,
    social_image character varying,
    title character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE comments (
    id bigint NOT NULL,
    ancestry character varying,
    body_html character varying(255),
    body_markdown character varying(255),
    commentable_id bigint,
    commentable_type character varying,
    created_at timestamp without time zone NOT NULL,
    deleted boolean  ,
    edited boolean  ,
    edited_at timestamp without time zone,
    hidden_by_commentable_user boolean  ,
    id_code character varying,
    markdown_character_count integer,
    positive_reactions_count integer   NOT NULL,
    processed_html character varying(255),
    public_reactions_count integer   NOT NULL,
    reactions_count integer   NOT NULL,
    receive_notifications boolean  ,
    score integer  ,
    spaminess_rating integer  ,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE comments_new (
    id bigint   NOT NULL,
    ancestry character varying,
    body_html character varying(255),
    body_markdown character varying(255),
    commentable_id bigint,
    commentable_type_int public.comments_commentable_type_value,
    created_at timestamp without time zone NOT NULL,
    deleted boolean  ,
    edited boolean  ,
    edited_at timestamp without time zone,
    hidden_by_commentable_user boolean  ,
    id_code character varying,
    markdown_character_count integer,
    positive_reactions_count integer   NOT NULL,
    processed_html character varying(255),
    public_reactions_count integer   NOT NULL,
    reactions_count integer   NOT NULL,
    receive_notifications boolean  ,
    score integer  ,
    spaminess_rating integer  ,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE comments_storage (
    id bigint   NOT NULL,
    ancestry character varying,
    body_html character varying(255),
    body_markdown character varying(255),
    commentable_id bigint,
    commentable_type public.comments_commentable_type_storage,
    created_at timestamp without time zone NOT NULL,
    deleted boolean  ,
    edited boolean  ,
    edited_at timestamp without time zone,
    hidden_by_commentable_user boolean  ,
    id_code character varying,
    markdown_character_count integer,
    positive_reactions_count integer   NOT NULL,
    processed_html character varying(255),
    public_reactions_count integer   NOT NULL,
    reactions_count integer   NOT NULL,
    receive_notifications boolean  ,
    score integer  ,
    spaminess_rating integer  ,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE consumer_apps (
    id bigint NOT NULL,
    active boolean   NOT NULL,
    app_bundle character varying NOT NULL,
    auth_key character varying,
    created_at timestamp(6) without time zone NOT NULL,
    last_error character varying,
    platform character varying NOT NULL,
    team_id character varying,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE consumer_apps_storage (
    id bigint   NOT NULL,
    active boolean   NOT NULL,
    app_bundle character varying NOT NULL,
    auth_key character varying,
    created_at timestamp(6) without time zone NOT NULL,
    last_error character varying,
    platform public.consumer_apps_platform_storage NOT NULL,
    team_id character varying,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE credits (
    id bigint NOT NULL,
    cost double precision  ,
    created_at timestamp without time zone NOT NULL,
    organization_id bigint,
    purchase_id bigint,
    purchase_type character varying,
    spent boolean  ,
    spent_at timestamp without time zone,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE credits_storage (
    id bigint   NOT NULL,
    cost double precision  ,
    created_at timestamp without time zone NOT NULL,
    organization_id bigint,
    purchase_id bigint,
    purchase_type public.credits_purchase_type_storage,
    spent boolean  ,
    spent_at timestamp without time zone,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE data_update_scripts (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    error character varying(255),
    file_name character varying,
    finished_at timestamp without time zone,
    run_at timestamp without time zone,
    status integer   NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE devices (
    id bigint NOT NULL,
    app_bundle character varying,
    consumer_app_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    platform character varying NOT NULL,
    token character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE devices_storage (
    id bigint   NOT NULL,
    app_bundle character varying,
    consumer_app_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    platform public.devices_platform_storage NOT NULL,
    token character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE discussion_locks (
    id bigint NOT NULL,
    article_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    locking_user_id bigint NOT NULL,
    notes character varying(255),
    reason character varying(255),
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE display_ad_events (
    id bigint NOT NULL,
    category character varying,
    context_type character varying,
    created_at timestamp without time zone NOT NULL,
    display_ad_id bigint,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE display_ad_events_storage (
    id bigint   NOT NULL,
    category public.display_ad_events_category_storage,
    context_type public.display_ad_events_context_type_storage,
    created_at timestamp without time zone NOT NULL,
    display_ad_id bigint,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE display_ads (
    id bigint NOT NULL,
    approved boolean  ,
    body_markdown character varying(255),
    clicks_count integer  ,
    created_at timestamp without time zone NOT NULL,
    impressions_count integer  ,
    organization_id bigint,
    placement_area character varying,
    processed_html character varying(255),
    published boolean  ,
    success_rate double precision  ,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE display_ads_new (
    id bigint   NOT NULL,
    approved boolean  ,
    body_markdown character varying(255),
    clicks_count integer  ,
    created_at timestamp without time zone NOT NULL,
    impressions_count integer  ,
    organization_id bigint,
    placement_area_int public.display_ads_placement_area_value,
    processed_html character varying(255),
    published boolean  ,
    success_rate double precision  ,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE display_ads_storage (
    id bigint   NOT NULL,
    approved boolean  ,
    body_markdown character varying(255),
    clicks_count integer  ,
    created_at timestamp without time zone NOT NULL,
    impressions_count integer  ,
    organization_id bigint,
    placement_area public.display_ads_placement_area_storage,
    processed_html character varying(255),
    published boolean  ,
    success_rate double precision  ,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE email_authorizations (
    id bigint NOT NULL,
    confirmation_token character varying,
    created_at timestamp without time zone NOT NULL,
    json_data jsonb   NOT NULL,
    type_of character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint,
    verified_at timestamp without time zone
);

CREATE TABLE email_authorizations_storage (
    id bigint   NOT NULL,
    confirmation_token character varying,
    created_at timestamp without time zone NOT NULL,
    json_data jsonb   NOT NULL,
    type_of public.email_authorizations_type_of_storage NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint,
    verified_at timestamp without time zone
);

CREATE TABLE events (
    id bigint NOT NULL,
    category character varying,
    cover_image character varying,
    created_at timestamp without time zone NOT NULL,
    description_html character varying(255),
    description_markdown character varying(255),
    ends_at timestamp without time zone,
    host_name character varying,
    live_now boolean  ,
    location_name character varying,
    location_url character varying,
    profile_image character varying,
    published boolean,
    slug character varying,
    starts_at timestamp without time zone,
    title character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE feedback_messages (
    id bigint NOT NULL,
    affected_id bigint,
    category character varying,
    created_at timestamp without time zone,
    feedback_type character varying,
    message character varying(255),
    offender_id bigint,
    reported_url character varying,
    reporter_id bigint,
    status character varying   ,
    updated_at timestamp without time zone
);

CREATE TABLE feedback_messages_storage (
    id bigint   NOT NULL,
    affected_id bigint,
    category public.feedback_messages_category_storage,
    created_at timestamp without time zone,
    feedback_type character varying,
    message character varying(255),
    offender_id bigint,
    reported_url character varying,
    reporter_id bigint,
    status public.feedback_messages_status_storage,
    updated_at timestamp without time zone
);

CREATE TABLE field_test_events (
    id bigint NOT NULL,
    created_at timestamp without time zone,
    field_test_membership_id bigint,
    name character varying
);

CREATE TABLE field_test_memberships (
    id bigint NOT NULL,
    converted boolean  ,
    created_at timestamp without time zone,
    experiment character varying,
    participant_id character varying,
    participant_type character varying,
    variant character varying
);

CREATE TABLE flipper_features (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    key character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE flipper_gates (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    feature_key character varying NOT NULL,
    key character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "value" character varying
);

CREATE TABLE follows (
    id bigint NOT NULL,
    blocked boolean   NOT NULL,
    created_at timestamp without time zone,
    explicit_points double precision  ,
    followable_id bigint NOT NULL,
    followable_type character varying NOT NULL,
    follower_id bigint NOT NULL,
    follower_type character varying NOT NULL,
    implicit_points double precision  ,
    points double precision  ,
    subscription_status character varying    NOT NULL,
    updated_at timestamp without time zone
);

CREATE TABLE follows_new (
    id bigint   NOT NULL,
    blocked boolean   NOT NULL,
    created_at timestamp without time zone,
    explicit_points double precision  ,
    followable_id bigint NOT NULL,
    followable_type character varying NOT NULL,
    follower_id bigint NOT NULL,
    follower_type character varying NOT NULL,
    implicit_points double precision  ,
    points double precision  ,
    subscription_status_int public.follows_subscription_status_value NOT NULL,
    updated_at timestamp without time zone
);

CREATE TABLE follows_storage (
    id bigint   NOT NULL,
    blocked boolean NOT NULL,
    created_at timestamp without time zone,
    explicit_points double precision  ,
    followable_id bigint NOT NULL,
    followable_type character varying NOT NULL,
    follower_id bigint NOT NULL,
    follower_type character varying NOT NULL,
    implicit_points double precision  ,
    points double precision  ,
    subscription_status character varying    NOT NULL,
    updated_at timestamp without time zone
);

CREATE TABLE github_issues (
    id bigint NOT NULL,
    category character varying,
    created_at timestamp without time zone NOT NULL,
    issue_serialized character varying,
    processed_html character varying,
    updated_at timestamp without time zone NOT NULL,
    url character varying
);

CREATE TABLE github_issues_storage (
    id bigint   NOT NULL,
    category public.github_issues_category_storage,
    created_at timestamp without time zone NOT NULL,
    issue_serialized character varying,
    processed_html character varying,
    updated_at timestamp without time zone NOT NULL,
    url character varying
);

CREATE TABLE github_repos (
    id bigint NOT NULL,
    additional_note character varying,
    bytes_size integer,
    created_at timestamp without time zone NOT NULL,
    description character varying,
    featured boolean  ,
    fork boolean  ,
    github_id_code bigint,
    info_hash character varying(255),
    "language" character varying,
    name character varying,
    priority integer  ,
    stargazers_count integer,
    updated_at timestamp without time zone NOT NULL,
    url character varying,
    user_id bigint,
    watchers_count integer
);

CREATE TABLE html_variant_successes (
    id bigint NOT NULL,
    article_id bigint,
    created_at timestamp without time zone NOT NULL,
    html_variant_id bigint,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE html_variant_trials (
    id bigint NOT NULL,
    article_id bigint,
    created_at timestamp without time zone NOT NULL,
    html_variant_id bigint,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE html_variants (
    id bigint NOT NULL,
    approved boolean  ,
    created_at timestamp without time zone NOT NULL,
    "group" character varying,
    html character varying(255),
    name character varying,
    published boolean  ,
    success_rate double precision  ,
    target_tag character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE html_variants_new (
    id bigint   NOT NULL,
    approved boolean  ,
    created_at timestamp without time zone NOT NULL,
    group_int public.html_variants_group_value,
    html character varying(255),
    name character varying,
    published boolean  ,
    success_rate double precision  ,
    target_tag character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE html_variants_storage (
    id bigint   NOT NULL,
    approved boolean  ,
    created_at timestamp without time zone NOT NULL,
    "group" public.html_variants_group_storage,
    html character varying(255),
    name character varying,
    published boolean  ,
    success_rate double precision  ,
    target_tag character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE identities (
    id bigint NOT NULL,
    auth_data_dump character varying(255),
    created_at timestamp without time zone NOT NULL,
    provider character varying,
    secret character varying,
    token character varying,
    uid character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE identities_new (
    id bigint   NOT NULL,
    auth_data_dump character varying(255),
    created_at timestamp without time zone NOT NULL,
    provider_int public.identities_provider_value,
    secret character varying,
    token character varying,
    uid character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE identities_storage (
    id bigint   NOT NULL,
    auth_data_dump character varying(255),
    created_at timestamp without time zone NOT NULL,
    provider public.identities_provider_storage,
    secret character varying,
    token character varying,
    uid character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE mentions (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    mentionable_id bigint,
    mentionable_type character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE mentions_new (
    id bigint   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    mentionable_id bigint,
    mentionable_type_int public.mentions_mentionable_type_value,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE mentions_storage (
    id bigint   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    mentionable_id bigint,
    mentionable_type public.mentions_mentionable_type_storage,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE messages (
    id bigint NOT NULL,
    chat_action character varying,
    chat_channel_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    edited_at timestamp without time zone,
    message_html character varying NOT NULL,
    message_markdown character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE navigation_links (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    display_only_when_signed_in boolean  ,
    icon character varying NOT NULL,
    name character varying NOT NULL,
    "position" integer,
    section integer   NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    url character varying NOT NULL
);

CREATE TABLE navigation_links_storage (
    id bigint   NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    display_only_when_signed_in boolean,
    icon character varying NOT NULL,
    name character varying NOT NULL,
    "position" integer,
    section integer   NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    url character varying NOT NULL
);

CREATE TABLE notes (
    id bigint NOT NULL,
    author_id bigint,
    content character varying(255),
    created_at timestamp without time zone NOT NULL,
    noteable_id bigint,
    noteable_type character varying,
    reason character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE notes_new (
    id bigint   NOT NULL,
    author_id bigint,
    content character varying(255),
    created_at timestamp without time zone NOT NULL,
    noteable_id bigint,
    noteable_type_int public.notes_noteable_type_value,
    reason character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE notes_storage (
    id bigint   NOT NULL,
    author_id bigint,
    content character varying(255),
    created_at timestamp without time zone NOT NULL,
    noteable_id bigint,
    noteable_type public.notes_noteable_type_storage,
    reason character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE notification_subscriptions (
    id bigint NOT NULL,
    config character varying(255)   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    notifiable_id bigint NOT NULL,
    notifiable_type character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE notification_subscriptions_new (
    id bigint   NOT NULL,
    config character varying(255)   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    notifiable_id bigint NOT NULL,
    notifiable_type_int public.notification_subscriptions_notifiable_type_value NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE notification_subscriptions_storage (
    id bigint   NOT NULL,
    config public.notification_subscriptions_config_storage NOT NULL,
    created_at timestamp without time zone NOT NULL,
    notifiable_id bigint NOT NULL,
    notifiable_type public.notification_subscriptions_notifiable_type_storage NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE notifications (
    id bigint NOT NULL,
    action character varying,
    created_at timestamp without time zone NOT NULL,
    json_data jsonb,
    notifiable_id bigint,
    notifiable_type character varying,
    notified_at timestamp without time zone,
    organization_id bigint,
    read boolean  ,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE oauth_access_grants (
    id bigint NOT NULL,
    application_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri character varying(255) NOT NULL,
    resource_owner_id bigint NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying,
    token character varying NOT NULL
);

CREATE TABLE oauth_access_tokens (
    id bigint NOT NULL,
    application_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    expires_in integer,
    previous_refresh_token character varying    NOT NULL,
    refresh_token character varying,
    resource_owner_id bigint,
    revoked_at timestamp without time zone,
    scopes character varying,
    token character varying NOT NULL
);

CREATE TABLE oauth_applications (
    id bigint NOT NULL,
    confidential boolean   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    name character varying NOT NULL,
    redirect_uri character varying(255) NOT NULL,
    scopes character varying    NOT NULL,
    secret character varying NOT NULL,
    uid character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE organization_memberships (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    organization_id bigint NOT NULL,
    type_of_user character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL,
    user_title character varying
);

CREATE TABLE organization_memberships_new (
    id bigint   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    organization_id bigint NOT NULL,
    type_of_user_int public.organization_memberships_type_of_user_value NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL,
    user_title character varying
);

CREATE TABLE organization_memberships_storage (
    id bigint   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    organization_id bigint NOT NULL,
    type_of_user public.organization_memberships_type_of_user_storage NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL,
    user_title character varying
);

CREATE TABLE organizations (
    id bigint NOT NULL,
    articles_count integer   NOT NULL,
    bg_color_hex character varying,
    company_size character varying,
    created_at timestamp without time zone NOT NULL,
    credits_count integer   NOT NULL,
    cta_body_markdown character varying(255),
    cta_button_text character varying,
    cta_button_url character varying,
    cta_processed_html character varying(255),
    dark_nav_image character varying,
    email character varying,
    github_username character varying,
    last_article_at timestamp without time zone,
    latest_article_updated_at timestamp without time zone,
    location character varying,
    name character varying,
    nav_image character varying,
    old_old_slug character varying,
    old_slug character varying,
    profile_image character varying,
    profile_updated_at timestamp without time zone,
    proof character varying(255),
    secret character varying,
    slug character varying,
    spent_credits_count integer   NOT NULL,
    story character varying,
    summary character varying(255),
    tag_line character varying,
    tech_stack character varying,
    text_color_hex character varying,
    twitter_username character varying,
    unspent_credits_count integer   NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    url character varying
);

CREATE TABLE page_views (
    id bigint NOT NULL,
    article_id bigint,
    counts_for_number_of_views integer  ,
    created_at timestamp without time zone NOT NULL,
    domain character varying,
    path character varying,
    referrer character varying,
    time_tracked_in_seconds integer  ,
    updated_at timestamp without time zone NOT NULL,
    user_agent character varying,
    user_id bigint
);

CREATE TABLE pages (
    id bigint NOT NULL,
    body_html character varying(255),
    body_json jsonb,
    body_markdown character varying(255),
    created_at timestamp without time zone NOT NULL,
    description character varying,
    is_top_level_path boolean  ,
    landing_page boolean   NOT NULL,
    processed_html character varying(255),
    slug character varying,
    social_image character varying,
    template character varying,
    title character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE pages_storage (
    id bigint   NOT NULL,
    body_html character varying(255),
    body_json jsonb,
    body_markdown character varying(255),
    created_at timestamp without time zone NOT NULL,
    description character varying,
    is_top_level_path boolean  ,
    landing_page boolean   NOT NULL,
    processed_html character varying(255),
    slug character varying,
    social_image character varying,
    template public.pages_template_storage,
    title character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE podcast_episode_appearances (
    id bigint NOT NULL,
    approved boolean   NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    featured_on_user_profile boolean   NOT NULL,
    podcast_episode_id bigint NOT NULL,
    role character varying    NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE podcast_episode_appearances_storage (
    id bigint   NOT NULL,
    approved boolean   NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    featured_on_user_profile boolean   NOT NULL,
    podcast_episode_id bigint NOT NULL,
    role public.podcast_episode_appearances_role_storage NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE podcast_episodes (
    id bigint NOT NULL,
    any_comments_hidden boolean  ,
    body character varying(255),
    comments_count integer   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    duration_in_seconds integer,
    guid character varying NOT NULL,
    https boolean  ,
    image character varying,
    itunes_url character varying,
    media_url character varying NOT NULL,
    podcast_id bigint,
    processed_html character varying(255),
    published_at timestamp without time zone,
    quote character varying(255),
    reachable boolean  ,
    reactions_count integer   NOT NULL,
    slug character varying NOT NULL,
    social_image character varying,
    status_notice character varying,
    subtitle character varying,
    summary character varying(255),
    title character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    website_url character varying
);

CREATE TABLE podcast_ownerships (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    podcast_id bigint NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE podcasts (
    id bigint NOT NULL,
    android_url character varying,
    created_at timestamp without time zone NOT NULL,
    creator_id bigint,
    description character varying(255),
    feed_url character varying NOT NULL,
    image character varying NOT NULL,
    itunes_url character varying,
    main_color_hex character varying NOT NULL,
    overcast_url character varying,
    pattern_image character varying,
    published boolean  ,
    reachable boolean  ,
    slug character varying NOT NULL,
    soundcloud_url character varying,
    status_notice character varying(255)  ,
    title character varying NOT NULL,
    twitter_username character varying,
    "unique_website_url?" boolean  ,
    updated_at timestamp without time zone NOT NULL,
    website_url character varying
);

CREATE TABLE poll_options (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    markdown character varying,
    poll_id bigint,
    poll_votes_count integer   NOT NULL,
    processed_html character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE poll_skips (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    poll_id bigint,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE poll_votes (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    poll_id bigint NOT NULL,
    poll_option_id bigint NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE polls (
    id bigint NOT NULL,
    article_id bigint,
    created_at timestamp without time zone NOT NULL,
    poll_options_count integer   NOT NULL,
    poll_skips_count integer   NOT NULL,
    poll_votes_count integer   NOT NULL,
    prompt_html character varying,
    prompt_markdown character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE profile_field_groups (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    description character varying,
    name character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE profile_fields (
    id bigint NOT NULL,
    attribute_name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    description character varying,
    display_area integer   NOT NULL,
    input_type integer   NOT NULL,
    label public.citext NOT NULL,
    placeholder_text character varying,
    profile_field_group_id bigint,
    show_in_onboarding boolean   NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE profile_fields_storage (
    id bigint   NOT NULL,
    attribute_name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    description character varying,
    display_area integer   NOT NULL,
    input_type integer   NOT NULL,
    label public.citext NOT NULL,
    placeholder_text character varying,
    profile_field_group_id bigint,
    show_in_onboarding boolean NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE profile_pins (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    pinnable_id bigint,
    pinnable_type character varying,
    profile_id bigint,
    profile_type character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE profile_pins_new (
    id bigint   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    pinnable_id bigint,
    pinnable_type_int public.profile_pins_pinnable_type_value,
    profile_id bigint,
    profile_type character varying,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE profile_pins_storage (
    id bigint   NOT NULL,
    created_at timestamp without time zone NOT NULL,
    pinnable_id bigint,
    pinnable_type public.profile_pins_pinnable_type_storage,
    profile_id bigint,
    profile_type public.profile_pins_profile_type_storage,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE profiles (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    data jsonb   NOT NULL,
    location character varying,
    summary character varying(255),
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL,
    website_url character varying
);

CREATE TABLE rating_votes (
    id bigint NOT NULL,
    article_id bigint,
    context character varying   ,
    created_at timestamp without time zone NOT NULL,
    "group" character varying,
    rating double precision,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE rating_votes_new (
    id bigint   NOT NULL,
    article_id bigint,
    context_int public.rating_votes_context_value,
    created_at timestamp without time zone NOT NULL,
    "group" character varying,
    rating double precision,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE rating_votes_storage (
    id bigint   NOT NULL,
    article_id bigint,
    context public.rating_votes_context_storage,
    created_at timestamp without time zone NOT NULL,
    "group" public.rating_votes_group_storage,
    rating double precision,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE reactions (
    id bigint NOT NULL,
    category character varying,
    created_at timestamp without time zone NOT NULL,
    points double precision  ,
    reactable_id bigint,
    reactable_type character varying,
    status character varying   ,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE reactions_new (
    id bigint   NOT NULL,
    category character varying,
    created_at timestamp without time zone NOT NULL,
    points double precision  ,
    reactable_id bigint,
    reactable_type_int public.reactions_reactable_type_value,
    status character varying   ,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE reactions_storage (
    id bigint   NOT NULL,
    category public.reactions_category_storage,
    created_at timestamp without time zone NOT NULL,
    points double precision  ,
    reactable_id bigint,
    reactable_type public.reactions_reactable_type_storage,
    status public.reactions_status_storage,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE response_templates (
    id bigint NOT NULL,
    content character varying(255) NOT NULL,
    content_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    title character varying NOT NULL,
    type_of character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE response_templates_new (
    id bigint   NOT NULL,
    content character varying(255) NOT NULL,
    content_type_int public.response_templates_content_type_value NOT NULL,
    created_at timestamp without time zone NOT NULL,
    title character varying NOT NULL,
    type_of character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE response_templates_storage (
    id bigint   NOT NULL,
    content character varying(255) NOT NULL,
    content_type public.response_templates_content_type_storage NOT NULL,
    created_at timestamp without time zone NOT NULL,
    title character varying NOT NULL,
    type_of public.response_templates_type_of_storage NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE roles (
    id bigint NOT NULL,
    created_at timestamp without time zone,
    name character varying,
    resource_id bigint,
    resource_type character varying,
    updated_at timestamp without time zone
);

CREATE TABLE roles_new (
    id bigint   NOT NULL,
    created_at timestamp without time zone,
    name_int public.roles_name_value,
    resource_id bigint,
    resource_type character varying,
    updated_at timestamp without time zone
);

CREATE TABLE roles_storage (
    id bigint   NOT NULL,
    created_at timestamp without time zone,
    name public.roles_name_storage,
    resource_id bigint,
    resource_type public.roles_resource_type_storage,
    updated_at timestamp without time zone
);

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);

CREATE TABLE settings_authentications (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "value" character varying(255),
    var character varying NOT NULL
);

CREATE TABLE settings_campaigns (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "value" character varying(255),
    var character varying NOT NULL
);

CREATE TABLE settings_communities (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "value" character varying(255),
    var character varying NOT NULL
);

CREATE TABLE settings_rate_limits (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "value" character varying(255),
    var character varying NOT NULL
);

CREATE TABLE settings_smtp (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "value" character varying(255),
    var character varying NOT NULL
);

CREATE TABLE settings_user_experiences (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "value" character varying(255),
    var character varying NOT NULL
);

CREATE TABLE site_configs (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "value" character varying(255),
    var character varying NOT NULL
);

CREATE TABLE sponsorships (
    id bigint NOT NULL,
    blurb_html character varying(255),
    created_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone,
    featured_number integer   NOT NULL,
    instructions character varying(255),
    instructions_updated_at timestamp without time zone,
    level character varying NOT NULL,
    organization_id bigint,
    sponsorable_id bigint,
    sponsorable_type character varying,
    status character varying    NOT NULL,
    tagline character varying,
    updated_at timestamp without time zone NOT NULL,
    url character varying,
    user_id bigint
);

CREATE TABLE sponsorships_new (
    id bigint   NOT NULL,
    blurb_html character varying(255),
    created_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone,
    featured_number integer   NOT NULL,
    instructions character varying(255),
    instructions_updated_at timestamp without time zone,
    level_int public.sponsorships_level_value NOT NULL,
    organization_id bigint,
    sponsorable_id bigint,
    sponsorable_type character varying,
    status character varying    NOT NULL,
    tagline character varying,
    updated_at timestamp without time zone NOT NULL,
    url character varying,
    user_id bigint
);

CREATE TABLE sponsorships_storage (
    id bigint   NOT NULL,
    blurb_html character varying(255),
    created_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone,
    featured_number integer   NOT NULL,
    instructions character varying(255),
    instructions_updated_at timestamp without time zone,
    level public.sponsorships_level_storage NOT NULL,
    organization_id bigint,
    sponsorable_id bigint,
    sponsorable_type character varying,
    status public.sponsorships_status_storage NOT NULL,
    tagline character varying,
    updated_at timestamp without time zone NOT NULL,
    url character varying,
    user_id bigint
);

CREATE TABLE tag_adjustments (
    id bigint NOT NULL,
    adjustment_type character varying,
    article_id bigint,
    created_at timestamp without time zone NOT NULL,
    reason_for_adjustment character varying,
    status character varying,
    tag_id bigint,
    tag_name character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE tag_adjustments_new (
    id bigint   NOT NULL,
    adjustment_type character varying,
    article_id bigint,
    created_at timestamp without time zone NOT NULL,
    reason_for_adjustment character varying,
    status_int public.tag_adjustments_status_value,
    tag_id bigint,
    tag_name character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE tag_adjustments_storage (
    id bigint   NOT NULL,
    adjustment_type public.tag_adjustments_adjustment_type_storage,
    article_id bigint,
    created_at timestamp without time zone NOT NULL,
    reason_for_adjustment character varying,
    status public.tag_adjustments_status_storage,
    tag_id bigint,
    tag_name character varying,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);

CREATE TABLE taggings (
    id bigint NOT NULL,
    context character varying(128),
    created_at timestamp without time zone,
    tag_id bigint,
    taggable_id bigint,
    taggable_type character varying,
    tagger_id bigint,
    tagger_type character varying
);

CREATE TABLE tags (
    id bigint NOT NULL,
    alias_for character varying,
    badge_id bigint,
    bg_color_hex character varying,
    category character varying    NOT NULL,
    created_at timestamp without time zone,
    hotness_score integer  ,
    keywords_for_search character varying,
    mod_chat_channel_id bigint,
    name character varying,
    pretty_name character varying,
    profile_image character varying,
    requires_approval boolean  ,
    rules_html character varying(255),
    rules_markdown character varying(255),
    short_summary character varying,
    social_image character varying,
    social_preview_template character varying   ,
    submission_template character varying(255),
    supported boolean  ,
    taggings_count integer  ,
    text_color_hex character varying,
    updated_at timestamp without time zone,
    wiki_body_html character varying(255),
    wiki_body_markdown character varying(255)
);

CREATE TABLE tweets (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    extended_entities_serialized character varying(255),
    favorite_count integer,
    full_fetched_object_serialized character varying(255),
    hashtags_serialized character varying,
    in_reply_to_status_id_code character varying,
    in_reply_to_user_id_code character varying,
    in_reply_to_username character varying,
    is_quote_status boolean,
    last_fetched_at timestamp without time zone,
    media_serialized character varying(255),
    mentioned_usernames_serialized character varying,
    profile_image character varying,
    quoted_tweet_id_code character varying,
    retweet_count integer,
    source character varying,
    character varying(255) character varying,
    tweeted_at timestamp without time zone,
    twitter_id_code character varying,
    twitter_name character varying,
    twitter_uid character varying,
    twitter_user_followers_count integer,
    twitter_user_following_count integer,
    twitter_username character varying,
    updated_at timestamp without time zone NOT NULL,
    urls_serialized character varying(255),
    user_id bigint,
    user_is_verified boolean
);

CREATE TABLE user_blocks (
    id bigint NOT NULL,
    blocked_id bigint NOT NULL,
    blocker_id bigint NOT NULL,
    config character varying    NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE user_blocks_storage (
    id bigint   NOT NULL,
    blocked_id bigint NOT NULL,
    blocker_id bigint NOT NULL,
    config public.user_blocks_config_storage NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE user_subscriptions (
    id bigint NOT NULL,
    author_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    subscriber_email character varying NOT NULL,
    subscriber_id bigint NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_subscription_sourceable_id bigint,
    user_subscription_sourceable_type character varying
);

CREATE TABLE user_subscriptions_storage (
    id bigint   NOT NULL,
    author_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    subscriber_email character varying NOT NULL,
    subscriber_id bigint NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_subscription_sourceable_id bigint,
    user_subscription_sourceable_type public.user_subscriptions_user_subscription_sourceable_type_storage
);

CREATE TABLE users (
    id bigint NOT NULL,
    apple_username character varying,
    articles_count integer   NOT NULL,
    available_for character varying,
    badge_achievements_count integer   NOT NULL,
    behance_url character varying,
    bg_color_hex character varying,
    blocked_by_count bigint   NOT NULL,
    blocking_others_count bigint   NOT NULL,
    checked_code_of_conduct boolean  ,
    checked_terms_and_conditions boolean  ,
    comments_count integer   NOT NULL,
    confirmation_sent_at timestamp without time zone,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    credits_count integer   NOT NULL,
    current_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    currently_hacking_on character varying,
    currently_learning character varying,
    dribbble_url character varying,
    education character varying,
    email character varying,
    email_public boolean  ,
    employer_name character varying,
    employer_url character varying,
    employment_title character varying,
    encrypted_password character varying    NOT NULL,
    export_requested boolean  ,
    exported_at timestamp without time zone,
    facebook_url character varying,
    facebook_username character varying,
    failed_attempts integer  ,
    feed_fetched_at timestamp without time zone,
    following_orgs_count integer   NOT NULL,
    following_tags_count integer   NOT NULL,
    following_users_count integer   NOT NULL,
    github_repos_updated_at timestamp without time zone,
    github_username character varying,
    gitlab_url character varying,
    instagram_url character varying,
    invitation_accepted_at timestamp without time zone,
    invitation_created_at timestamp without time zone,
    invitation_limit integer,
    invitation_sent_at timestamp without time zone,
    invitation_token character varying,
    invitations_count integer  ,
    invited_by_id bigint,
    invited_by_type character varying,
    last_article_at timestamp without time zone ,
    last_comment_at timestamp without time zone,
    last_followed_at timestamp without time zone,
    last_moderation_notification timestamp without time zone,
    last_notification_activity timestamp without time zone,
    last_onboarding_page character varying,
    last_reacted_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    last_sign_in_ip inet,
    latest_article_updated_at timestamp without time zone,
    linkedin_url character varying,
    location character varying,
    locked_at timestamp without time zone,
    mastodon_url character varying,
    medium_url character varying,
    monthly_dues integer  ,
    mostly_work_with character varying,
    name character varying,
    old_old_username character varying,
    old_username character varying,
    onboarding_package_requested boolean  ,
    organization_info_updated_at timestamp without time zone,
    payment_pointer character varying,
    profile_image character varying,
    profile_updated_at timestamp without time zone,
    rating_votes_count integer   NOT NULL,
    reactions_count integer   NOT NULL,
    registered boolean  ,
    registered_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    remember_token character varying,
    reputation_modifier double precision  ,
    reset_password_sent_at timestamp without time zone,
    reset_password_token character varying,
    saw_onboarding boolean  ,
    score integer  ,
    secret character varying,
    sign_in_count integer   NOT NULL,
    signup_cta_variant character varying,
    spent_credits_count integer   NOT NULL,
    stackoverflow_url character varying,
    stripe_id_code character varying,
    subscribed_to_user_subscriptions_count integer   NOT NULL,
    summary character varying(255),
    text_color_hex character varying,
    twitch_url character varying,
    twitter_username character varying,
    unconfirmed_email character varying,
    unlock_token character varying,
    unspent_credits_count integer   NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    username character varying,
    website_url character varying,
    workshop_expiration timestamp without time zone,
    youtube_url character varying,
    CONSTRAINT users_username_not_null CHECK ((username IS NOT NULL))
);

CREATE TABLE users_gdpr_delete_requests (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    email character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id integer NOT NULL,
    username character varying
);

CREATE TABLE users_notification_settings (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    email_badge_notifications boolean   NOT NULL,
    email_comment_notifications boolean   NOT NULL,
    email_community_mod_newsletter boolean   NOT NULL,
    email_connect_messages boolean   NOT NULL,
    email_digest_periodic boolean   NOT NULL,
    email_follower_notifications boolean   NOT NULL,
    email_membership_newsletter boolean   NOT NULL,
    email_mention_notifications boolean   NOT NULL,
    email_newsletter boolean   NOT NULL,
    email_tag_mod_newsletter boolean   NOT NULL,
    email_unread_notifications boolean   NOT NULL,
    mobile_comment_notifications boolean   NOT NULL,
    mod_roundrobin_notifications boolean   NOT NULL,
    reaction_notifications boolean   NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL,
    welcome_notifications boolean   NOT NULL
);

CREATE TABLE users_roles (
    role_id bigint,
    user_id bigint
);

CREATE TABLE users_settings (
    id bigint NOT NULL,
    brand_color1 character varying   ,
    brand_color2 character varying   ,
    config_font integer   NOT NULL,
    config_navbar integer   NOT NULL,
    config_theme integer   NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    display_announcements boolean   NOT NULL,
    display_email_on_profile boolean   NOT NULL,
    display_sponsors boolean   NOT NULL,
    editor_version integer   NOT NULL,
    experience_level integer,
    feed_mark_canonical boolean   NOT NULL,
    feed_referential_link boolean   NOT NULL,
    feed_url character varying,
    inbox_guidelines character varying,
    inbox_type integer   NOT NULL,
    permit_adjacent_sponsors boolean  ,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE users_suspended_usernames (
    username_hash character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE webhook_endpoints (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    events character varying[] NOT NULL,
    oauth_application_id bigint,
    source character varying,
    target_url character varying NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE welcome_notifications (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);
-- Original Query
SELECT reactions.reactable_id FROM reactions WHERE reactions.category = 'hands' AND reactions.user_id = 6945 AND reactions.reactable_type = 'Comment' AND reactions.status <> 'archived' ORDER BY reactions.created_at DESC;
-- Rewritten Queries
SELECT reactions.reactable_id FROM reactions WHERE reactions.category = 'hands' AND reactions.user_id = 6945 AND reactions.reactable_type = 'Comment' AND reactions.status <> 'archived' ORDER BY reactions.created_at DESC LIMIT 1;
