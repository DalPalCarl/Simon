extends Node

var score : float = 0.0
var highscore : float = 0.0

func checkScore(sc):
	if sc > highscore:
		highscore = sc
	score = sc
