LEARNING_REATE = 0.0003

theta0 = 0
theta1 = 1

range = _.range

x = [50,60,70,80]
y = [1000,1100,1050,1200]
M = x.length

hypothesis = (x) => theta0 + theta1 * x

learn = (alpha) =>
	sum0 = 0
	sum1 = 0
	for i in range M
		diff = hypothesis(x[i]) - y[i]
		sum0 += diff
		sum1 += diff * x[i]

	theta0 -= alpha / M * sum0
	theta1 -= alpha / M * sum1

cost = =>
	sum = 0
	for i in range M
		diff = hypothesis(x[i]) - y[i]
		sum += diff*diff
	sum / (2*M)

for iteration in range 10
	learn LEARNING_REATE
	console.log "#{iteration} Cost: #{cost().toFixed(2)} Theta0: #{theta0.toFixed(2)} Theta1: #{theta1.toFixed(2)}"