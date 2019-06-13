import 'package:flutter/material.dart';

class Player {
  final Color color;
  final List<int> scores = [];
  final String name = "";

  Player(this.color);

  addScore(int score) {
    this.scores.add(score);
  }

  int getSum() {
    return this.scores.fold(0, (prev, element) => prev + element);
  }


}