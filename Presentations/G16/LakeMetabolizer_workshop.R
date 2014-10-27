## Code to run models and generate figures for Manuscript
#  This will be displayed when "manuscript.code()" function is called
#  A great outreach method for the package

library(LakeMetabolizer)

data.path = system.file('extdata', package="LakeMetabolizer")

sp.data = load.all.data('sparkling', data.path)

ts.data = sp.data$data #pull out just the timeseries data

plot(ts.data$datetime, ts.data$doobs_0.5, type='l', ylab='DO',xlab='date')

plot(ts.data$datetime, ts.data$par, type='l', ylab='PAR',xlab='date')

plot(ts.data$datetime, ts.data$wnd_2.0, type='l', ylab='PAR',xlab='date')

#calculate U10 and add it back onto the original
u10 = wind.scale(ts.data)
ts.data = rmv.vars(ts.data, 'wnd', ignore.offset=TRUE) #drop old wind speed column
ts.data = merge(ts.data, u10)                          #merge new u10 into big dataset

#show the scaled wind
lines(ts.data$datetime, ts.data$wnd_10, col='blue')

#Now calculate k600 using the Cole method
k600.cole = k.cole(ts.data)

ts.data = merge(ts.data, k600.cole)

kgas = k600.2.kGAS(ts.data)
ts.data = rmv.vars(merge(kgas, ts.data), 'k600')

o2.sat = o2.at.sat(ts.data[,c('datetime','wtr_0')])

ts.data = merge(o2.sat, ts.data)
z.mix = ts.meta.depths(get.vars(ts.data, 'wtr'), seasonal=TRUE)
names(z.mix) = c('datetime','z.mix', 'bottom')

#set z.mix to bottom of lake when undefined
z.mix[z.mix$z.mix <=0 | is.na(z.mix$z.mix), 'z.mix'] = 20 
ts.data = merge(ts.data, z.mix[,c('datetime','z.mix')])


#Plot the data
plot(ts.data$datetime, ts.data$z.mix, type='l', ylab='z.mix',xlab='date')



#OLS
ols.res = metab(ts.data, method='ols', 
            wtr.name='wtr_0.5', do.obs.name='doobs_0.5', irr.name='par')
#write.csv(res, 'sp.metab.ols.csv', row.names=FALSE)

#MLE
mle.res = metab(ts.data, method='mle', 
            wtr.name='wtr_0.5', do.obs.name='doobs_0.5', irr.name='par')

#Kalman
kalman.res = metab(ts.data, method='kalman', 
            wtr.name='wtr_0.5', do.obs.name='doobs_0.5', irr.name='par')

#Bayesian
bayes.res = metab(ts.data, method='bayesian', 
            wtr.name='wtr_0.5', do.obs.name='doobs_0.5', irr.name='par')

#Bookkeep
ts.data[, names(ts.data)%in%'par'] = as.numeric(ts.data[, names(ts.data)%in%'par'] >=0)

book.res = metab(ts.data, method='bookkeep', 
            wtr.name='wtr_0.5', do.obs.name='doobs_0.5', irr.name='par')

#Plot the metabolism results
par(mfrow=c(2,1), mar=c(1,4,1,1), las=1)
plot(ols.res[,2:3], type='l', col='black', ylim=c(-1,1))
lines(mle.res[,2:3], type='l', col='green')
lines(kalman.res[,2:3], type='l', col='yellow')
lines(bayes.res[,2:3], type='l', col='red')
lines(book.res[,2:3], type='l', col='blue')

plot(ols.res[,c(2,4)], type='l', col='black', ylim=c(-1,1))
lines(mle.res[,c(2,4)], type='l', col='green')
lines(kalman.res[,c(2,4)], type='l', col='yellow')
lines(bayes.res[,c(2,4)], type='l', col='red')
lines(book.res[,c(2,4)], type='l', col='blue')

legend('topleft', legend = c('OLS','MLE','Kalman','bayes','book'), col=c('black',
			'green','yellow','red','blue'), lty=2)
################################################################################
## Run trout bog
################################################################################
library(zoo)

data.path = system.file('extdata', package="LakeMetabolizer")

tb.data = load.all.data('troutbog', data.path)

ts.data = tb.data$data #pull out just the timeseries data

#Do a simple linear interpolation to fill the few missing temp values
wtr = get.vars(ts.data, 'wtr')
wtr_interp = data.frame(lapply(wtr[,-1], function(d)na.approx(d, na.rm=FALSE)))
wtr_interp$datetime = wtr$datetime

ts.data = merge(wtr_interp, rmv.vars(ts.data, 'wtr', ignore.offset=TRUE))

plot(ts.data$datetime, ts.data$doobs_0.25, type='l', ylab='DO',xlab='date')

plot(ts.data$datetime, ts.data$par, type='l', ylab='PAR',xlab='date')

plot(ts.data$datetime, ts.data$wnd_2, type='l', ylab='PAR',xlab='date')

#calculate U10 and add it back onto the original
u10 = wind.scale(ts.data)
ts.data = rmv.vars(ts.data, 'wnd', ignore.offset=TRUE) #drop old wind speed column
ts.data = merge(ts.data, u10)                          #merge new u10 into big dataset

#show the scaled wind
lines(ts.data$datetime, ts.data$wnd_10, col='blue')

#Now calculate k600 using the Cole method
k600.cole = k.cole(ts.data)

ts.data = merge(ts.data, k600.cole)

kgas = k600.2.kGAS(ts.data)
ts.data = rmv.vars(merge(kgas, ts.data), 'k600')

o2.sat = o2.at.sat(ts.data[,c('datetime','wtr_0')])

ts.data = merge(o2.sat, ts.data)
z.mix = ts.meta.depths(get.vars(ts.data, 'wtr'), seasonal=TRUE)
names(z.mix) = c('datetime','z.mix', 'bottom')

#set z.mix to bottom of lake when undefined
z.mix[z.mix$z.mix <=0 | is.na(z.mix$z.mix), 'z.mix'] = 1 
ts.data = merge(ts.data, z.mix[,c('datetime','z.mix')])


#Plot the data
plot(ts.data$datetime, ts.data$z.mix, type='l', ylab='z.mix',xlab='date')


#OLS
ols.res = metab(ts.data, method='ols', 
								wtr.name='wtr_0.5', do.obs.name='doobs_0.25', irr.name='par')
#write.csv(res, 'sp.metab.ols.csv', row.names=FALSE)

#MLE
mle.res = metab(ts.data, method='mle', 
								wtr.name='wtr_0.5', do.obs.name='doobs_0.25', irr.name='par')

#Kalman
kalman.res = metab(ts.data, method='kalman', 
									 wtr.name='wtr_0.5', do.obs.name='doobs_0.25', irr.name='par')

#Bayesian
bayes.res = metab(ts.data, method='bayesian', 
									wtr.name='wtr_0.5', do.obs.name='doobs_0.25', irr.name='par')

#Bookkeep
ts.data[, names(ts.data)%in%'par'] = as.numeric(ts.data[, names(ts.data)%in%'par'] >=0)

book.res = metab(ts.data, method='bookkeep', 
								 wtr.name='wtr_0.5', do.obs.name='doobs_0.25', irr.name='par')

#Plot the metabolism results
par(mfrow=c(2,1), mar=c(1,4,1,1), las=1)
plot(ols.res[,2:3], type='l', col='black', ylim=c(-1,1))
lines(mle.res[,2:3], type='l', col='green')
lines(kalman.res[,2:3], type='l', col='yellow')
lines(bayes.res[,2:3], type='l', col='red')
lines(book.res[,2:3], type='l', col='blue')

plot(ols.res[,c(2,4)], type='l', col='black', ylim=c(-1,1))
lines(mle.res[,c(2,4)], type='l', col='green')
lines(kalman.res[,c(2,4)], type='l', col='yellow')
lines(bayes.res[,c(2,4)], type='l', col='red')
lines(book.res[,c(2,4)], type='l', col='blue')

################################################################################
## Run Mendota
################################################################################
library(zoo)

data.path = system.file('extdata', package="LakeMetabolizer")

me.data = load.all.data('mendota', data.path)

ts.data = me.data$data #pull out just the timeseries data

#Do a simple linear interpolation to fill the few missing temp values
wtr = get.vars(ts.data, 'wtr')
wtr_interp = data.frame(lapply(wtr[,-1], function(d)na.approx(d, na.rm=FALSE)))
wtr_interp$datetime = wtr$datetime

ts.data = merge(wtr_interp, rmv.vars(ts.data, 'wtr', ignore.offset=TRUE))

plot(ts.data$datetime, ts.data$doobs_0.5, type='l', ylab='DO',xlab='date')

plot(ts.data$datetime, ts.data$par, type='l', ylab='PAR',xlab='date')

plot(ts.data$datetime, ts.data$wnd, type='l', ylab='Wind',xlab='date')

#calculate U10 and add it back onto the original
u10 = wind.scale(ts.data, wnd.z=3)
ts.data = rmv.vars(ts.data, 'wnd', ignore.offset=TRUE) #drop old wind speed column
ts.data = merge(ts.data, u10)                          #merge new u10 into big dataset

#show the scaled wind
lines(ts.data$datetime, ts.data$wnd_10, col='blue')

#Now calculate k600 using the Cole method
k600.cole = k.cole(ts.data)

ts.data = merge(ts.data, k600.cole)

kgas = k600.2.kGAS(ts.data)
ts.data = rmv.vars(merge(kgas, ts.data), 'k600')

o2.sat = o2.at.sat(ts.data[,c('datetime','wtr_0')])

ts.data = merge(o2.sat, ts.data)
z.mix = ts.meta.depths(get.vars(ts.data, 'wtr'), seasonal=TRUE)
names(z.mix) = c('datetime','z.mix', 'bottom')

#set z.mix to bottom of lake when undefined
z.mix[z.mix$z.mix <=0 | is.na(z.mix$z.mix), 'z.mix'] = 1 
ts.data = merge(ts.data, z.mix[,c('datetime','z.mix')])


#Plot the data
plot(ts.data$datetime, ts.data$z.mix, type='l', ylab='z.mix',xlab='date')


#OLS
ols.res = metab(ts.data, method='ols', 
								wtr.name='wtr_0.5', do.obs.name='doobs_0.5', irr.name='par')
#write.csv(res, 'sp.metab.ols.csv', row.names=FALSE)

#MLE
mle.res = metab(ts.data, method='mle', 
								wtr.name='wtr_0.5', do.obs.name='doobs_0.5', irr.name='par')

#Kalman
kalman.res = metab(ts.data, method='kalman', 
									 wtr.name='wtr_0.5', do.obs.name='doobs_0.5', irr.name='par')

#Bayesian
bayes.res = metab(ts.data, method='bayesian', 
									wtr.name='wtr_0.5', do.obs.name='doobs_0.5', irr.name='par')

#Bookkeep
ts.data[, names(ts.data)%in%'par'] = as.numeric(ts.data[, names(ts.data)%in%'par'] >=0)

book.res = metab(ts.data, method='bookkeep', 
								 wtr.name='wtr_0.5', do.obs.name='doobs_0.5', irr.name='par')

#Plot the metabolism results
par(mfrow=c(2,1), mar=c(1,4,1,1), las=1)
plot(ols.res[,2:3], type='l', col='black', ylim=c(-1,1))
lines(mle.res[,2:3], type='l', col='green')
lines(kalman.res[,2:3], type='l', col='yellow')
lines(bayes.res[,2:3], type='l', col='red')
lines(book.res[,2:3], type='l', col='blue')

plot(ols.res[,c(2,4)], type='l', col='black', ylim=c(-1,1))
lines(mle.res[,c(2,4)], type='l', col='green')
lines(kalman.res[,c(2,4)], type='l', col='yellow')
lines(bayes.res[,c(2,4)], type='l', col='red')
lines(book.res[,c(2,4)], type='l', col='blue')
