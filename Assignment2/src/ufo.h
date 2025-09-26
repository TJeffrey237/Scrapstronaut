#ifndef UFO_H
#define UFO_H

#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/classes/node2d.hpp>

namespace godot {

	class UFO : public Sprite2D {
		GDCLASS(UFO, Sprite2D)

	private:
		float speed;
		float turn_rate;
		double timeLimit;
		double timeRemaining;
		Node2D* target;

	protected:
		static void _bind_methods();

	public:
		UFO();
		~UFO();
		
		void destroy_ufo(bool expired_by_timer);
		void _ready() override;
		void _process(double delta) override;
		void set_speed(float p_speed);
		float get_speed() const;
		void set_turn_rate(float p_turn_rate);
		float get_turn_rate() const;
		void on_hit();
	};

}

#endif