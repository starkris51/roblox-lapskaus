--!strict
export type MovementConfigType = {
	PrimaryTangentAxis: Vector3,
	SecondaryTangentAxis: Vector3,
	MaxForce: number,
	AccelerationRateMoving: number,
	AccelerationRateStopping: number,
	TargetVelocityMultiplier: number,
}

local MovementConfig: MovementConfigType = {
	PrimaryTangentAxis = Vector3.new(1, 0, 0),
	SecondaryTangentAxis = Vector3.new(0, 0, 1),
	MaxForce = 10000,
	AccelerationRateMoving = 8,
	AccelerationRateStopping = 6,
	TargetVelocityMultiplier = 60,
} :: MovementConfigType

return MovementConfig
