extends Node
#this script is to test if the player is looking at an object that can be 
#interacted with (button pressed, item grabbed?)
#all creadit to this video: 
#https://www.youtube.com/watch?v=5YT4bFw9k4U
#for this method of iteraction. 

#NOTE, THIS IS A BASE SCRIPT, IF YOU WANT MORE INTERACTIONS (Flip switch, spawn monster, explode violently)
		#you must duplicate this script, modify it for the specific interactable thingy, 
														#then attach it to said thingy
#functionally we created a new type of node
	

class_name Interactable

#var spawnedCreature = "some Entity" #change this to grab whatever the spawner wants to spawn

func get_interaction_text():
	return "Interactable" # + spawnedCreature

func interact():
	print("Interacted with %s " % name)
