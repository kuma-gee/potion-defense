class_name Obstacle
extends Node3D

signal activated()
signal deactivated()
signal finished()

func activate():
	activated.emit()

func deactivate():
	deactivated.emit()
