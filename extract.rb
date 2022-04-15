require_relative 'constropt/constr_extractor/engine'
require_relative 'constropt/constr_extractor/traversor'
require_relative 'constropt/constr_extractor/builtin_extractor'
require_relative 'constropt/constr_extractor/db_extractor'
require_relative 'constropt/constr_extractor/id_extractor'
require_relative 'constropt/constr_extractor/class_inheritance_extractor'
require_relative 'constropt/constr_extractor/state_machine_extractor'
require_relative 'constropt/constr_extractor/hasone_belongto_extractor'
require_relative 'constropt/constr_extractor/constraint'
require_relative 'constropt/constr_extractor/serializer' 


appname = "openproject"
engine = Engine.new("constropt/constr_extractor/test/data/#{appname}_models")
root = engine.run

builtin_t = Traversor.new(BuiltinExtractor.new)
builtin_t.traverse(root)

class_inheritance_t = Traversor.new(ClassInheritanceExtractor.new)
class_inheritance_t.traverse(root)

state_machine = Traversor.new(StateMachineExtractor.new)
state_machine.traverse(root)
constraints_cnt = engine.get_constraints_cnt(root)
puts "After extracting state machine constraints, # of constraints #{constraints_cnt}"

hasone_belongto = Traversor.new(HasoneBelongtoExtractor.new)
hasone_belongto.traverse(root)
constraints_cnt = engine.get_constraints_cnt(root)
puts "After extracting hasone belongto constraints, # of constraints #{constraints_cnt}"

db_t = Traversor.new(DBExtractor.new("constropt/constr_extractor/test/data/#{appname}_db/schema.rb"))
db_t.traverse(root)
constraints_cnt = engine.get_constraints_cnt(root)
puts "After extracting db constraints, # of constraints #{constraints_cnt}"

id_t = Traversor.new(IdExtractor.new)
id_t.traverse(root)

Serializer.serialize_tree(root, "constraints/#{appname}")
