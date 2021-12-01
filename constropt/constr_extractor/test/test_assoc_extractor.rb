require 'yard'
require 'oj'
require_relative '../assoc_extractor'
require_relative '../class_node'

def test_naive
  class_def = <<-FOO
    class Test
        has_and_belongs_to_many :groups,
                          :join_table => "groups_users",
                          :after_add => Proc.new { |user, group| group.user_added(user) },
                          :after_remove => Proc.new { |user, group| group.user_removed(user) }
        has_many :changesets, :dependent => :nullify
        has_one :preference, :dependent => :destroy, :class_name => "UserPreference"
        has_one :rss_token, lambda { where "action='feeds'" }, :class_name => "Token"
        has_one :api_token, lambda { where "action='api'" }, :class_name => "Token"
        has_one :email_address, lambda { where :is_default => true }, :autosave => true
        has_many :email_addresses, :dependent => :delete_all
        belongs_to :auth_source
        belongs_to :auth_source_new, :class_name => 'AuthSource'
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  assoc_extractor = AssocExtractor.new
  assoc_extractor.visit(node, {})
  puts "# of extracted constraints: #{node.constraints}"
end

test_naive
