# 2023-027-ChessMaximumMoves

Går igenom flera miljoner mästarpartier i jakt på en ställning med maximalt antal möjliga drag.
För att undvika åtta damer, sätts en gräns att ursprungligt material ska finnas, inget extra.

Genom att köra en process framåt och en annan bakåt, halveras beräkningstiden.

Just nu ser denna ut att vara vinnaren:

* Filen heter 2020-04
* Partiet är nummer 48452 i denna fil, mellan haychesspoker och Keipo
* FEN visar att ställningen uppstår före vits 30:e drag
* De 77 dragen listas i alfabetisk sortering
* Dragföljden

* Typiskt är att alla pjäser är närvarande, minus de flesta bönder.
* Ställningen är öppen så att pjäserna får stor rörlighet.
* Oftast är det vit som leder. M a o få svarta pjäser.

* Ganska enkelt att stuva om pjäserna och komma upp i 80 möjliga drag.

readPGN: 2020-04

77 48452 haychesspoker-Keipo

rk3r2/ppb2P2/2bnN2p/q2p1B2/3Q1B2/P4N2/5K2/1R5R w - - 1 30

Q d4a1 d4a4 d4a7 d4b2 d4b4 d4b6 d4c3 d4c4 d4c5 d4d1 d4d2 d4d3 d4d5 d4e3 d4e4 d4e5 d4f6 d4g7 d4h8 (19)
R b1a1 b1b2 b1b3 b1b4 b1b5 b1b6 b1b7 b1c1 b1d1 b1e1 b1f1 b1g1 (12)
R h1c1 h1d1 h1e1 h1f1 h1g1 h1h2 h1h3 h1h4 h1h5 h1h6 (10)
B f4c1 f4d2 f4d6 f4e3 f4e5 f4g3 f4g5 f4h2 f4h6 (9)
B f5c2 f5d3 f5e4 f5g4 f5g6 f5h3 f5h7 (7)
N f3d2 f3e1 f3e5 f3g1 f3g5 f3h2 f3h4 (7)
N e6c5 e6c7 e6d8 e6f8 e6g5 e6g7 (6)
K f2e2 f2e3 f2f1 f2g1 f2g2 f2g3 (6)
P a3a4 (1)

1. e4 e6 2. d4 d5 3. Nd2 Nf6 4. e5 Nfd7 5. c3 c5 6. f4 cxd4 7. cxd4 f5 8. Ndf3 Nb6 9. Bd3 Nc6 10. Ne2 Bd7
11. a3 Na5 12. b3 Be7 13. h3 Bc6 14. g4 fxg4 15. hxg4 h6 16. Bd2 Nc8 17. f5 Qb6 18. Nf4 exf5 19. gxf5 Bd8 20. f6 gxf6
21. Bg6+ Kd7 22. Bf5+ Kc7 23. Ne6+ Kb8 24. exf6 Bc7 25. f7 Nd6 26. Bf4 Nxb3 27. Rb1 Qa5+ 28. Kf2 Nxd4 29. Qxd4 Rf8 30. Nxf8 Nxf5
31. Bxc7+ Qxc7 32. Nd7+

# Parti med 79 drag som inte räknas pga av att vit skänker bort pjäserna.

readPGN: 2016-05
79 17358 Tomek_ol-Tranquilou
   5q2/6kp/pb2p3/1p2n2P/PP2b3/2r5/6r1/4K3 b - - 4 39
   a6a5 b5a4 b6a5 b6a7 b6c5 b6c7 b6d4 b6d8 b6e3 b6f2 b6g1 c3a3 c3b3 c3c1 c3c2 c3c4 c3c5 c3c6 c3c7 c3c8 c3d3 c3e3 c3f3 c3g3 c3h3 e4a8 e4b1 e4b7 e4c2 e4c6 e4d3 e4d5 e4f3 e4f5 e4g6 e5c4 e5c6 e5d3 e5d7 e5f3 e5f7 e5g4 e5g6 f8a8 f8b4 f8b8 f8c5 f8c8 f8d6 f8d8 f8e7 f8e8 f8f1 f8f2 f8f3 f8f4 f8f5 f8f6 f8f7 f8g8 f8h8 g2a2 g2b2 g2c2 g2d2 g2e2 g2f2 g2g1 g2g3 g2g4 g2g5 g2g6 g2h2 g7f6 g7f7 g7g8 g7h6 g7h8 h7h6
   1. e4 c5 2. Nf3 e6 3. c3 Nf6 4. e5 Nd5 5. d4 cxd4 6. cxd4 b6 7. Bc4 Bb7 8. O-O d6 9. Qe2 Nd7 10. Rd1 dxe5 11. dxe5 Be7 12. Bxd5 Bxd5 13. Nc3 Bb7 14. Bf4 a6 15. Na4 b5 16. Nc3 Rc8 17. Rac1 Rc4 18. Bg3 Qa8 19. b3 Rc8 20. Ne1 Nc5 21. b4 Nd7 22. a3 Bc6 23. h4 O-O 24. Nd3 Bxg2 25. Nf4 Bc6 26. Qg4 Nxe5 27. Qxg7+ Kxg7 28. Nxe6+ fxe6 29. Rd8 Bxd8 30. Ne4 Bxe4 31. Rc6 Nxc6 32. Be5+ Nxe5 33. f4 Rxf4 34. Kh2 Rc3 35. h5 Rf2+ 36. Kg1 Bb6 37. a4 Rg2+ 38. Kf1 Qf8+ 39. Ke1 Rc1#

# Parti med 76 drag. ok.

readPGN: 2019-06
75 24189 BMWHero-SAV88888
   rn1R1bk1/1q2pr2/p3Q1pp/1p6/4N3/4B3/PP2BPPP/2R3K1 w - - 6 21
   a2a3 a2a4 b2b3 b2b4 c1a1 c1b1 c1c2 c1c3 c1c4 c1c5 c1c6 c1c7 c1c8 c1d1 c1e1 c1f1 d8b8 d8c8 d8d1 d8d2 d8d3 d8d4 d8d5 d8d6 d8d7 d8e8 d8f8 e2b5 e2c4 e2d1 e2d3 e2f1 e2f3 e2g4 e2h5 e3a7 e3b6 e3c5 e3d2 e3d4 e3f4 e3g5 e3h6 e4c3 e4c5 e4d2 e4d6 e4f6 e4g3 e4g5 e6a6 e6b3 e6b6 e6c4 e6c6 e6c8 e6d5 e6d6 e6d7 e6e5 e6e7 e6f5 e6f6 e6f7 e6g4 e6g6 e6h3 f2f3 f2f4 g1f1 g1h1 g2g3 g2g4 h2h3 h2h4
   1. d4 Nf6 2. Nf3 g6 3. c4 Bg7 4. e3 O-O 5. Be2 d5 6. cxd5 Nxd5 7. e4 Nf6 8. Nc3 c5 9. O-O cxd4 10. Nxd4 a6 11. Be3 Bd7 12. Qb3 b5 13. e5 Be6 14. Nxe6 fxe6 15. exf6 Rxf6 16. Ne4 Rf7 17. Qxe6 h6 18. Rfd1 Qc7 19. Rac1 Qb7 20. Rd8+ Bf8 21. Qxg6+ Rg7 22. Qe6+ Rf7 23. Bxh6 Nc6 24. Rxa8 Qxa8 25. Rxc6 Bxh6 26. Qxh6 Rg7 27. Qe6+ Kf8 28. Rc8+ Qxc8 29. Qxc8+ Kf7 30. Bh5+ Rg6 31. Qf5+ Ke8 32. Bxg6+ Kd8 33. Qd5+ Kc7 34. Bf5 Kb6 35. Qc5+ Ka5 36. Nc3 e6 37. b4#

76 24189 BMWHero-SAV88888
   rn1R1bk1/1q2pr2/p3Q2p/1p6/4N3/4B3/PP2BPPP/2R3K1 w - - 3 23
   a2a3 a2a4 b2b3 b2b4 c1a1 c1b1 c1c2 c1c3 c1c4 c1c5 c1c6 c1c7 c1c8 c1d1 c1e1 c1f1 d8b8 d8c8 d8d1 d8d2 d8d3 d8d4 d8d5 d8d6 d8d7 d8e8 d8f8 e2b5 e2c4 e2d1 e2d3 e2f1 e2f3 e2g4 e2h5 e3a7 e3b6 e3c5 e3d2 e3d4 e3f4 e3g5 e3h6 e4c3 e4c5 e4d2 e4d6 e4f6 e4g3 e4g5 e6a6 e6b3 e6b6 e6c4 e6c6 e6c8 e6d5 e6d6 e6d7 e6e5 e6e7 e6f5 e6f6 e6f7 e6g4 e6g6 e6h3 e6h6 f2f3 f2f4 g1f1 g1h1 g2g3 g2g4 h2h3 h2h4
   1. d4 Nf6 2. Nf3 g6 3. c4 Bg7 4. e3 O-O 5. Be2 d5 6. cxd5 Nxd5 7. e4 Nf6 8. Nc3 c5 9. O-O cxd4 10. Nxd4 a6 11. Be3 Bd7 12. Qb3 b5 13. e5 Be6 14. Nxe6 fxe6 15. exf6 Rxf6 16. Ne4 Rf7 17. Qxe6 h6 18. Rfd1 Qc7 19. Rac1 Qb7 20. Rd8+ Bf8 21. Qxg6+ Rg7 22. Qe6+ Rf7 23. Bxh6 Nc6 24. Rxa8 Qxa8 25. Rxc6 Bxh6 26. Qxh6 Rg7 27. Qe6+ Kf8 28. Rc8+ Qxc8 29. Qxc8+ Kf7 30. Bh5+ Rg6 31. Qf5+ Ke8 32. Bxg6+ Kd8 33. Qd5+ Kc7 34. Bf5 Kb6 35. Qc5+ Ka5 36. Nc3 e6 37. b4#