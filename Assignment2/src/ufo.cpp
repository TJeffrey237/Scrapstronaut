#include "ufo.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/engine.hpp>

using namespace godot;

void UFO::_bind_methods() {
	// binding methods
	ClassDB::bind_method(D_METHOD("set_speed", "p_speed"), &UFO::set_speed);
	ClassDB::bind_method(D_METHOD("get_speed"), &UFO::get_speed);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "missile_speed"), "set_speed", "get_speed");

	ClassDB::bind_method(D_METHOD("set_turn_rate", "p_turn_rate"), &UFO::set_turn_rate);
	ClassDB::bind_method(D_METHOD("get_turn_rate"), &UFO::get_turn_rate);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ufo_turn_rate"), "set_turn_rate", "get_turn_rate");

	// creating a signal to be sent out
	ClassDB::bind_method(D_METHOD("destroy_ufo"), &UFO::destroy_ufo);
	ADD_SIGNAL(MethodInfo("ufo_destroyed", PropertyInfo(Variant::BOOL, "expired")));

	ClassDB::bind_method(D_METHOD("on_hit"), &UFO::on_hit);
}

UFO::UFO() {
	// Initialize any variables here.
	speed = 250.0f;
	turn_rate = 5.0f;
	timeLimit = 6.0;
	timeRemaining = timeLimit;
	target = nullptr;
}

UFO::~UFO() {
	// Add your cleanup here.
}

// function to set the speed of ufo
void UFO::set_speed(float p_speed) {
	speed = p_speed;
}

// function to get the speed of ufo
float UFO::get_speed() const {
	return speed;
}

// function to set turn rate of ufo
void UFO::set_turn_rate(float p_turn_rate) {
	turn_rate = p_turn_rate;
}

// function to get turn rate of ufo
float UFO::get_turn_rate() const {
	return turn_rate;
}

void UFO::_ready() {
	// prevents the node from running in editor
	if (Engine::get_singleton()->is_editor_hint()) {
		return;
	}

	// looks for a node in the group "player" to set as target
	SceneTree* tree = get_tree();
	if (tree) {
		target = Object::cast_to<Node2D>(tree->get_first_node_in_group("player"));
	}
}

void UFO::_process(double delta) {
	// check for a target
	if (!target) {
		return;
	}

	// decrement the time limit
	timeRemaining -= delta;

	// destroy ufo after a certain period of time
	if (timeRemaining <= 0.0) {
		destroy_ufo(true);
		return;
	}

	// calculates the target position for ufo
	Vector2 target_pos = target->get_global_position();
	Vector2 current_pos = get_global_position();
	Vector2 target_direction = (target_pos - current_pos).normalized();

	Vector2 current_direction = Vector2(1, 0).rotated(get_rotation());

	// calculate angle of rotation based on turn rate
	float angle_to_target = current_direction.angle_to(target_direction);
	float max_rotation_delta = turn_rate * delta;
	angle_to_target = CLAMP(angle_to_target, -max_rotation_delta, max_rotation_delta);

	// rotates the node to face the target
	set_rotation(get_rotation() + angle_to_target);
	current_direction = current_direction.rotated(angle_to_target);

	// move node towards target
	set_global_position(current_pos + current_direction * speed * delta);
}

// function that will destroy ufo
void UFO::destroy_ufo(bool expired_by_timer) {
	// signals the destruction of ufo
	emit_signal("ufo_destroyed", expired_by_timer);
	// frees the node
	queue_free();
}

// function for when ufo hits target
void UFO::on_hit() {
	destroy_ufo(false);
}