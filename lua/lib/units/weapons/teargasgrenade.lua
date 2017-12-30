DeathVoxTearGasGrenade = DeathVoxTearGasGrenade or blt_class(TearGasGrenade)

function DeathVoxTearGasGrenade:set_properties(props)
	self.radius = props.radius or 0
	self.duration = props.duration or 0
	self.damage = props.damage or 0

	if Network:is_server() then
		managers.network:session():send_to_peers("sync_vox_grenade_properties", self._unit, self.radius, self.damage * 10, self.duration, self._unit:position())
	end
end

function DeathVoxTearGasGrenade:detonate()
	local now = TimerManager:game():time()
	self._remove_t = now + self.duration
	self._damage_t = now + 1
	local position = self._unit:position()
	local sound_source = SoundDevice:create_source("tear_gas_source")

	sound_source:set_position(position)
	sound_source:post_event("grenade_gas_explode")
	World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/explosion_smoke_grenade"),
		position = position,
		normal = self._unit:rotation():y()
	})

	local parent = self._unit:orientation_object()
	self._smoke_effect = World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/cs_grenade_smoke"),
		parent = parent
	})
	local blurzone_radius = self.radius * 1.5

	managers.environment_controller:set_blurzone(self._unit:key(), 1, self._unit:position(), blurzone_radius, 0, true)
	if Network:is_server() then
		managers.network:session():send_to_peers("sync_vox_grenade_detonate", self._unit)
	end

end

function DeathVoxTearGasGrenade:destroy()
	if self._smoke_effect then
		World:effect_manager():fade_kill(self._smoke_effect)
	end
	managers.environment_controller:set_blurzone(self._unit:key(), 0)
end