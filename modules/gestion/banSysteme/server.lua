time = (os.time())+8759
print(time)
timeLeft = (time - os.time())/3600
print('Il vous reste '..timeLeft..' heures avant la fin de votre ban.')
date = os.date("%d/%m/%Y", time)
print(date)