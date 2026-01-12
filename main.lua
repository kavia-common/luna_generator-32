--Start To Write RL

Fix1HPCB=false
Fix2HPCB=false
Fix3HPCB=false
Fix4HPCB=false
Fix5HPCB=false
Fix6HPCB=false
Fix7HPCB=false
Fix8HPCB=false
Fix9HPCB=false
Fix10HPCB=false
Fix11HPCB=false

GrHPcb = false

Fix1Finish=false
Fix2Finish=false
Fix3Finish=false
Fix4Finish=false
Fix5Finish=false
Fix6Finish=false
Fix7Finish=false
Fix8Finish=false
Fix9Finish=false
Fix10Finish=false
Fix11Finish=false

Fix1Test=false
Fix2Test=false
Fix3Test=false
Fix4Test=false
Fix5Test=false
Fix6Test=false
Fix7Test=false
Fix8Test=false
Fix9Test=false
Fix10Test=false
Fix11Test=false

Scan1=false
Scan2=false

Rec1=""
CheckResult=1
Result=""

Connect=false

Testing1=false
Testing2=false
Testing3=false
Testing4=false
Testing5=false
Testing6=false
Testing7=false
Testing8=false
Testing9=false
Testing10=false
Testing11=false
rets = 0
ss = 0
ss1 = 0
ss2 = 0
b1 = 0
b2 = 0
b3 = 0
boot1 = false
boot2 = false
boot2 = false
bootOk1 = false
bootOk2 = false
bootOk3 = false
smcMove = false
x1 = 0
x2 = 0
sn3 = ""
tt = 0
RobotServoOn()
function Timer66()
	tt = tt + 1
	DELAY(0.5)
	--print(tt)
	if tt < 3 then
		DO("TowerLightG","ON")
		DO("TowerLightY","OFF")
		DO("TowerLightR","OFF")
	end
	if tt > 120 then
		DO("TowerLightG","OFF")
		DO("TowerLightY","OFF")
		DO("TowerLightR","OFF")
	end
end

function SpeedLow()
	SpdJ (30)
	AccJ (7)
	DecJ (7)
	SpdL (1000)
	AccL (10000)
	DecL (10000)
	Accur ("ROUGH")
end 

function SpeedHigh()
	SpdJ (40)
	AccJ (50)
	DecJ (50)
	SpdL (1000)
	AccL (12000)
	DecL (12000)
	Accur ("ROUGH")
end 

function Speed(percent)
    SpdJ(percent)
    AccJ(percent-10)
    DecJ(percent-10)
    SpdL(percent*20)
    AccL(percent*250)
    DecL(percent*250)
    Accur ("ROUGH")
    --print("SpdJ="..percent..+"AccJ=")--..(percent-10)..+"DecJ="..(percent-10))
end

-- Placeholder for point definitions
--[[
-- Point definitions would be generated here
]]

function PlacePASS()
	MovP("SBuffer")
	MovP("BufFixSpare")
	--WAIT(DI,21,"OFF")
	MovL("FixSpare"+Z(80))	
    MovL("FixSpare")
	
	DO("Gripper2","OFF")
	WAIT(DI,18,"ON")
	MovL("FixSpare"+Z(80))	
	MovL("BufFixSpare")
	MovP("SBuffer")
end

function PlaceFAIL3()
	MovP("SBuffer")
	MovP("BufCvFail3")
::RetryFail::
	--if DI(24)==OFF  then			
            ddd=ReadModbus(0x3FFC,"W")
            if DI(16)==OFF  then
            	ddd = 0
            end
            MovL("CvFail3" +Y(300) +Z(90))
            MovL("CvFail3" +Y(300) +Z(30))	
            MovL("CvFail3" +Y(ddd*90) +Z(30))	
            MovL("CvFail3" +Y(ddd*90))            
            DO("Gripper1","OFF")
            WAIT(DI,21,"ON")
            MovL("CvFail3" +Y(ddd*90) +Z(90))
            MovP("BufCvFail3")
            MovP("SBuffer")
            ddd = ddd+1
            if ddd > 2 then
            	DO("TowerLightG","OFF")
            	DO("TowerLightY","OFF")
            	DO("TowerLightR","ON")
            	WAIT(DI,10,"ON")
            	WAIT(DI,10,"OFF")
            	DELAY(1)               
            	ddd = 0
            	DO("TowerLightG","ON")
            	DO("TowerLightY","OFF")
            	DO("TowerLightR","OFF")
            end
            WriteModbus(0x3FFC,"W",ddd)    
	--else
    --    DELAY(1)
    --    goto RetryFail
    --end 	
	
	MovP("SBuffer")
end

function PlaceFailGripper(Gripper)	
	if Gripper == 1 then
        MovP("BufScanFail")	
    elseif Gripper == 2 then
    	MovP("BufCvFail1")
    end
	if DI("SsFail1") == OFF then
        fff = 0
        WriteModbus(0x3FFD,"W",fff)
    end     
  ::CheckCvFail::
    fff=ReadModbus(0x3FFD,"W")	
	if  fff < 5 then
		if Gripper == 1 then		
            MovP("BufScanFail")		
            MovP("ScanFail" +Y(fff*90) +Z(130))	
            MovL("ScanFail" +Y(fff*90))            
            DO("Gripper1","OFF")
            WAIT(DI,21,"ON")            
            fff = fff+1
            WriteModbus(0x3FFD,"W",fff)
            MovP("ScanFail" +Y(fff*90) +Z(130))
            MovP("BufScanFail")
        elseif Gripper == 2 then
        	MovP("BufCvFail1")		
            MovP("CvFail1" +Y(fff*90) +Z(130))	
            MovL("CvFail1" +Y(fff*90))            
            DO("Gripper2","OFF")
            WAIT(DI,18,"ON")            
            fff = fff+1
            WriteModbus(0x3FFD,"W",fff)
            MovP("CvFail1" +Y(fff*90) +Z(130))
            MovP("BufCvFail1")
        end 
        if fff > 4 then
            DO("TowerLightG","OFF")
            DO("TowerLightY","ON")
            WAIT(DI,10,"OFF")
            fff = 0
            WriteModbus(0x3FFD,"W",fff)
            DO("TowerLightG","ON")
            DO("TowerLightY","OFF")
            DO("TowerLightR","OFF")
        end                
        MovP("SBuffer")          
    else
        DO("TowerLightG","OFF")
        DO("TowerLightY","ON")
        WAIT(DI,10,"OFF")
        fff = 0
        WriteModbus(0x3FFD,"W",fff)
        DO("TowerLightG","ON")
        DO("TowerLightY","OFF")
        DO("TowerLightR","OFF")
        goto CheckCvFail
    end  
end
 
function PickToCVIN()
	WAIT(DI,14,"ON")
	WAIT(DI,21,"ON")
	WAIT(DI,20,"OFF")	
	MovP("SBuffer")
	MovP("BufLifter")	
	MovP("BufLifter1")
    MovL("Lifter1")    
    DO("Gripper1","ON")
	WAIT(DI,20,"ON")	
    MovL("BufLifter1")
    MovP("BufLifter")
    MovP("SBuffer")
   
end


function PlaceToFix1()
	WAIT(ExtDI,{3,2},"ON")
	MovP("BufFix1")
    MovP("Fix1" + Z(80)+X(20))
    MovP("Fix1" +Z(40)+X(20))
    MovP("Fix1" +Z(40))
    MovL("Fix1")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix1" + Z(80))
    MovP("BufFix1")
end


function PlaceToFix2()
	WAIT(ExtDI,{3,3},"ON")
	MovP("BufFix2")
    MovP("Fix2" + Z(80)+X(20))
    MovP("Fix2" +Z(40)+X(20))
    MovP("Fix2" +Z(40))
    MovL("Fix2")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix2" + Z(80))
    MovP("BufFix2")
end


function PlaceToFix3()
	WAIT(ExtDI,{3,5},"ON")
	MovP("BufFix3")
    MovP("Fix3" + Z(80)+X(20))
    MovP("Fix3" +Z(40)+X(20))
    MovP("Fix3" +Z(40))
    MovL("Fix3")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix3" + Z(80))
    MovP("BufFix3")
end


function PlaceToFix4()
	WAIT(ExtDI,{3,7},"ON")
	MovP("BufFix4")
    MovP("Fix4" + Z(80)+X(20))
    MovP("Fix4" +Z(40)+X(20))
    MovP("Fix4" +Z(40))
    MovL("Fix4")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix4" + Z(80))
    MovP("BufFix4")
end


function PlaceToFix5()
	WAIT(ExtDI,{3,8},"ON")
	MovP("BufFix5")
    MovP("Fix5" + Z(80)+X(20))
    MovP("Fix5" +Z(40)+X(20))
    MovP("Fix5" +Z(40))
    MovL("Fix5")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix5" + Z(80))
    MovP("BufFix5")
end


function PlaceToFix6()
	WAIT(ExtDI,{3,9},"ON")
	MovP("BufFix6")
    MovP("Fix6" + Z(80)+X(20))
    MovP("Fix6" +Z(40)+X(20))
    MovP("Fix6" +Z(40))
    MovL("Fix6")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix6" + Z(80))
    MovP("BufFix6")
end


function PlaceToFix7()
	WAIT(ExtDI,{3,10},"ON")
	MovP("BufFix7")
    MovP("Fix7" + Z(80)+X(20))
    MovP("Fix7" +Z(40)+X(20))
    MovP("Fix7" +Z(40))
    MovL("Fix7")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix7" + Z(80))
    MovP("BufFix7")
end


function PlaceToFix8()
	WAIT(ExtDI,{3,11},"ON")
	MovP("BufFix8")
    MovP("Fix8" + Z(80)+X(20))
    MovP("Fix8" +Z(40)+X(20))
    MovP("Fix8" +Z(40))
    MovL("Fix8")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix8" + Z(80))
    MovP("BufFix8")
end


function PlaceToFix9()
	WAIT(ExtDI,{3,12},"ON")
	MovP("BufFix9")
    MovP("Fix9" + Z(80)+X(20))
    MovP("Fix9" +Z(40)+X(20))
    MovP("Fix9" +Z(40))
    MovL("Fix9")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix9" + Z(80))
    MovP("BufFix9")
end


function PlaceToFix10()
	WAIT(ExtDI,{3,13},"ON")
	MovP("BufFix10")
    MovP("Fix10" + Z(80)+X(20))
    MovP("Fix10" +Z(40)+X(20))
    MovP("Fix10" +Z(40))
    MovL("Fix10")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix10" + Z(80))
    MovP("BufFix10")
end


function PlaceToFix11()
	WAIT(ExtDI,{3,14},"ON")
	MovP("BufFix11")
    MovP("Fix11" + Z(80)+X(20))
    MovP("Fix11" +Z(40)+X(20))
    MovP("Fix11" +Z(40))
    MovL("Fix11")    
    DO("Gripper1","OFF")
    WAIT(DI,21,"ON")	
    MovL("Fix11" + Z(80))
    MovP("BufFix11")
end


function PickToFix1()
	WAIT(ExtDI,{3,2},"ON")	
	Fix1Finish=false
	MovP("BufFix1" +RZ(-180) +RX(ReadPoint("BufFix1","RX")-(180)) +RY(ReadPoint("BufFix1","RY")*(-1)))
    MovP("Fix1" +RZ(-180) +RX(ReadPoint("Fix1","RX")-(180)) +RY(ReadPoint("Fix1","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix1" +RZ(-180) +RX(ReadPoint("Fix1","RX")-(180)) +RY(ReadPoint("Fix1","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix1HPCB=false
    MovL("Fix1" +RZ(-180) +RX(ReadPoint("Fix1","RX")-(180)) +RY(ReadPoint("Fix1","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix1" +RZ(-180) +RX(ReadPoint("BufFix1","RX")-(180)) +RY(ReadPoint("BufFix1","RY")*(-1)))
end


function PickToFix2()
	WAIT(ExtDI,{3,3},"ON")	
	Fix2Finish=false
	MovP("BufFix2" +RZ(-180) +RX(ReadPoint("BufFix2","RX")-(180)) +RY(ReadPoint("BufFix2","RY")*(-1)))
    MovP("Fix2" +RZ(-180) +RX(ReadPoint("Fix2","RX")-(180)) +RY(ReadPoint("Fix2","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix2" +RZ(-180) +RX(ReadPoint("Fix2","RX")-(180)) +RY(ReadPoint("Fix2","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix2HPCB=false
    MovL("Fix2" +RZ(-180) +RX(ReadPoint("Fix2","RX")-(180)) +RY(ReadPoint("Fix2","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix2" +RZ(-180) +RX(ReadPoint("BufFix2","RX")-(180)) +RY(ReadPoint("BufFix2","RY")*(-1)))
end


function PickToFix3()
	WAIT(ExtDI,{3,5},"ON")	
	Fix3Finish=false
	MovP("BufFix3" +RZ(-180) +RX(ReadPoint("BufFix3","RX")-(180)) +RY(ReadPoint("BufFix3","RY")*(-1)))
    MovP("Fix3" +RZ(-180) +RX(ReadPoint("Fix3","RX")-(180)) +RY(ReadPoint("Fix3","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix3" +RZ(-180) +RX(ReadPoint("Fix3","RX")-(180)) +RY(ReadPoint("Fix3","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix3HPCB=false
    MovL("Fix3" +RZ(-180) +RX(ReadPoint("Fix3","RX")-(180)) +RY(ReadPoint("Fix3","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix3" +RZ(-180) +RX(ReadPoint("BufFix3","RX")-(180)) +RY(ReadPoint("BufFix3","RY")*(-1)))
end


function PickToFix4()
	WAIT(ExtDI,{3,7},"ON")	
	Fix4Finish=false
	MovP("BufFix4" +RZ(-180) +RX(ReadPoint("BufFix4","RX")-(180)) +RY(ReadPoint("BufFix4","RY")*(-1)))
    MovP("Fix4" +RZ(-180) +RX(ReadPoint("Fix4","RX")-(180)) +RY(ReadPoint("Fix4","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix4" +RZ(-180) +RX(ReadPoint("Fix4","RX")-(180)) +RY(ReadPoint("Fix4","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix4HPCB=false
    MovL("Fix4" +RZ(-180) +RX(ReadPoint("Fix4","RX")-(180)) +RY(ReadPoint("Fix4","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix4" +RZ(-180) +RX(ReadPoint("BufFix4","RX")-(180)) +RY(ReadPoint("BufFix4","RY")*(-1)))
end


function PickToFix5()
	WAIT(ExtDI,{3,8},"ON")	
	Fix5Finish=false
	MovP("BufFix5" +RZ(-180) +RX(ReadPoint("BufFix5","RX")-(180)) +RY(ReadPoint("BufFix5","RY")*(-1)))
    MovP("Fix5" +RZ(-180) +RX(ReadPoint("Fix5","RX")-(180)) +RY(ReadPoint("Fix5","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix5" +RZ(-180) +RX(ReadPoint("Fix5","RX")-(180)) +RY(ReadPoint("Fix5","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix5HPCB=false
    MovL("Fix5" +RZ(-180) +RX(ReadPoint("Fix5","RX")-(180)) +RY(ReadPoint("Fix5","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix5" +RZ(-180) +RX(ReadPoint("BufFix5","RX")-(180)) +RY(ReadPoint("BufFix5","RY")*(-1)))
end


function PickToFix6()
	WAIT(ExtDI,{3,9},"ON")	
	Fix6Finish=false
	MovP("BufFix6" +RZ(-180) +RX(ReadPoint("BufFix6","RX")-(180)) +RY(ReadPoint("BufFix6","RY")*(-1)))
    MovP("Fix6" +RZ(-180) +RX(ReadPoint("Fix6","RX")-(180)) +RY(ReadPoint("Fix6","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix6" +RZ(-180) +RX(ReadPoint("Fix6","RX")-(180)) +RY(ReadPoint("Fix6","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix6HPCB=false
    MovL("Fix6" +RZ(-180) +RX(ReadPoint("Fix6","RX")-(180)) +RY(ReadPoint("Fix6","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix6" +RZ(-180) +RX(ReadPoint("BufFix6","RX")-(180)) +RY(ReadPoint("BufFix6","RY")*(-1)))
end


function PickToFix7()
	WAIT(ExtDI,{3,10},"ON")	
	Fix7Finish=false
	MovP("BufFix7" +RZ(-180) +RX(ReadPoint("BufFix7","RX")-(180)) +RY(ReadPoint("BufFix7","RY")*(-1)))
    MovP("Fix7" +RZ(-180) +RX(ReadPoint("Fix7","RX")-(180)) +RY(ReadPoint("Fix7","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix7" +RZ(-180) +RX(ReadPoint("Fix7","RX")-(180)) +RY(ReadPoint("Fix7","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix7HPCB=false
    MovL("Fix7" +RZ(-180) +RX(ReadPoint("Fix7","RX")-(180)) +RY(ReadPoint("Fix7","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix7" +RZ(-180) +RX(ReadPoint("BufFix7","RX")-(180)) +RY(ReadPoint("BufFix7","RY")*(-1)))
end


function PickToFix8()
	WAIT(ExtDI,{3,11},"ON")	
	Fix8Finish=false
	MovP("BufFix8" +RZ(-180) +RX(ReadPoint("BufFix8","RX")-(180)) +RY(ReadPoint("BufFix8","RY")*(-1)))
    MovP("Fix8" +RZ(-180) +RX(ReadPoint("Fix8","RX")-(180)) +RY(ReadPoint("Fix8","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix8" +RZ(-180) +RX(ReadPoint("Fix8","RX")-(180)) +RY(ReadPoint("Fix8","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix8HPCB=false
    MovL("Fix8" +RZ(-180) +RX(ReadPoint("Fix8","RX")-(180)) +RY(ReadPoint("Fix8","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix8" +RZ(-180) +RX(ReadPoint("BufFix8","RX")-(180)) +RY(ReadPoint("BufFix8","RY")*(-1)))
end


function PickToFix9()
	WAIT(ExtDI,{3,12},"ON")	
	Fix9Finish=false
	MovP("BufFix9" +RZ(-180) +RX(ReadPoint("BufFix9","RX")-(180)) +RY(ReadPoint("BufFix9","RY")*(-1)))
    MovP("Fix9" +RZ(-180) +RX(ReadPoint("Fix9","RX")-(180)) +RY(ReadPoint("Fix9","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix9" +RZ(-180) +RX(ReadPoint("Fix9","RX")-(180)) +RY(ReadPoint("Fix9","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix9HPCB=false
    MovL("Fix9" +RZ(-180) +RX(ReadPoint("Fix9","RX")-(180)) +RY(ReadPoint("Fix9","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix9" +RZ(-180) +RX(ReadPoint("BufFix9","RX")-(180)) +RY(ReadPoint("BufFix9","RY")*(-1)))
end


function PickToFix10()
	WAIT(ExtDI,{3,13},"ON")	
	Fix10Finish=false
	MovP("BufFix10" +RZ(-180) +RX(ReadPoint("BufFix10","RX")-(180)) +RY(ReadPoint("BufFix10","RY")*(-1)))
    MovP("Fix10" +RZ(-180) +RX(ReadPoint("Fix10","RX")-(180)) +RY(ReadPoint("Fix10","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix10" +RZ(-180) +RX(ReadPoint("Fix10","RX")-(180)) +RY(ReadPoint("Fix10","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix10HPCB=false
    MovL("Fix10" +RZ(-180) +RX(ReadPoint("Fix10","RX")-(180)) +RY(ReadPoint("Fix10","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix10" +RZ(-180) +RX(ReadPoint("BufFix10","RX")-(180)) +RY(ReadPoint("BufFix10","RY")*(-1)))
end


function PickToFix11()
	WAIT(ExtDI,{3,14},"ON")	
	Fix11Finish=false
	MovP("BufFix11" +RZ(-180) +RX(ReadPoint("BufFix11","RX")-(180)) +RY(ReadPoint("BufFix11","RY")*(-1)))
    MovP("Fix11" +RZ(-180) +RX(ReadPoint("Fix11","RX")-(180)) +RY(ReadPoint("Fix11","RY")*(-1)) +Z(80)+Y(-4))
    MovL("Fix11" +RZ(-180) +RX(ReadPoint("Fix11","RX")-(180)) +RY(ReadPoint("Fix11","RY")*(-1))+Y(-4))

	DO("Gripper2","ON")
	WAIT(DI,19,"ON")
    Fix11HPCB=false
    MovL("Fix11" +RZ(-180) +RX(ReadPoint("Fix11","RX")-(180)) +RY(ReadPoint("Fix11","RY")*(-1)) +Z(80)+Y(-4))
    MovP("BufFix11" +RZ(-180) +RX(ReadPoint("BufFix11","RX")-(180)) +RY(ReadPoint("BufFix11","RY")*(-1)))
end

RBSocket01=SocketClass("192.168.1.100",2000," ",",",nil, 0.3,5)
DELAY(3)
 while true do
    RBrets = RBSocket01:Receive()
    if RBrets~=nil then
    	CMD=RBrets[1]    	
    	RBrets=nil
    end 
    if CMD=="01_R" or CMD=="01_R,01_R" then
    	print("msgR=",CMD)
    	CMD=""
    	break
    end 
end

function TcpIpScan()
    print("Client started.");
    DELAY (0.5)
    while true do
    	dataScan=ReadModbus(0x3140,"W")
        if dataScan==1 then
            WriteModbus(0x3140,"W",0)
            ABC = "01_S"
            RBSocket01:Send(ABC)
            print("senddata1: 01_S")
            break            
        end 
    end	    
    while true do
        RBrets = RBSocket01:Receive()          
        if RBrets ~= nil then
            CMD=RBrets[1]   
            print("CMD: ", CMD)
            --ret = split (CMD,",")                  
            sn1 = CMD
            print("1 = ",sn1)
            --end
            RBrets = nil
            break            
        end
        
    end 
end


function ThreadFix1()	
		Enable1=ReadModbus(0x3001,"W")
		if Enable1==1 then
			if iStep1==1 then
				if Fix1Test==true then
					WAIT (ExtDI,{3,2},"ON")
					ExtDO(3,1,"ON")
					WAIT (ExtDI,{3,1},"ON")
					DELAY(0.5)
					WriteModbus(0x3101,"W",2)
    Fix1Finish=false
    iStep1=2					
				end	
			elseif iStep1==2 then
				if Fix1Finish==true then						
					ExtDO(3,1,"OFF")
					WAIT (ExtDI,{3,2},"ON")
					DELAY(0.5)					
					Testing1=false
					WriteModbus(0x3101,"W",1)
					Fix1Test=false
					iStep1 = 1
				else
    WriteModbus(0x3310,"W",1)
				end 
            end
		else
    Fix1Finish=false
			Fix1Test=false
			Fix1HPCB=false
			WriteModbus(0x3101,"W",1)
			iStep1 = 1
		end		 
end


function ThreadFix2()	
		Enable2=ReadModbus(0x3002,"W")
		if Enable2==1 then
			if iStep2==1 then
				if Fix2Test==true then
					WAIT (ExtDI,{3,3},"ON")
					ExtDO(3,2,"ON")
					WAIT (ExtDI,{3,2},"ON")
					DELAY(0.5)
					WriteModbus(0x3102,"W",2)
    Fix2Finish=false
    iStep2=2					
				end	
			elseif iStep2==2 then
				if Fix2Finish==true then						
					ExtDO(3,2,"OFF")
					WAIT (ExtDI,{3,3},"ON")
					DELAY(0.5)					
					Testing2=false
					WriteModbus(0x3102,"W",1)
					Fix2Test=false
					iStep2 = 1
				else
    WriteModbus(0x3320,"W",1)
				end 
            end
		else
    Fix2Finish=false
			Fix2Test=false
			Fix2HPCB=false
			WriteModbus(0x3102,"W",1)
			iStep2 = 1
		end		 
end


function ThreadFix3()	
		Enable3=ReadModbus(0x3003,"W")
		if Enable3==1 then
			if iStep3==1 then
				if Fix3Test==true then
					WAIT (ExtDI,{3,5},"ON")
					ExtDO(3,4,"ON")
					WAIT (ExtDI,{3,4},"ON")
					DELAY(0.5)
					WriteModbus(0x3103,"W",2)
    Fix3Finish=false
    iStep3=2					
				end	
			elseif iStep3==2 then
				if Fix3Finish==true then						
					ExtDO(3,4,"OFF")
					WAIT (ExtDI,{3,5},"ON")
					DELAY(0.5)					
					Testing3=false
					WriteModbus(0x3103,"W",1)
					Fix3Test=false
					iStep3 = 1
				else
    WriteModbus(0x3330,"W",1)
				end 
            end
		else
    Fix3Finish=false
			Fix3Test=false
			Fix3HPCB=false
			WriteModbus(0x3103,"W",1)
			iStep3 = 1
		end		 
end


function ThreadFix4()	
		Enable4=ReadModbus(0x3004,"W")
		if Enable4==1 then
			if iStep4==1 then
				if Fix4Test==true then
					WAIT (ExtDI,{3,7},"ON")
					ExtDO(3,6,"ON")
					WAIT (ExtDI,{3,6},"ON")
					DELAY(0.5)
					WriteModbus(0x3104,"W",2)
    Fix4Finish=false
    iStep4=2					
				end	
			elseif iStep4==2 then
				if Fix4Finish==true then						
					ExtDO(3,6,"OFF")
					WAIT (ExtDI,{3,7},"ON")
					DELAY(0.5)					
					Testing4=false
					WriteModbus(0x3104,"W",1)
					Fix4Test=false
					iStep4 = 1
				else
    WriteModbus(0x3340,"W",1)
				end 
            end
		else
    Fix4Finish=false
			Fix4Test=false
			Fix4HPCB=false
			WriteModbus(0x3104,"W",1)
			iStep4 = 1
		end		 
end


function ThreadFix5()	
		Enable5=ReadModbus(0x3005,"W")
		if Enable5==1 then
			if iStep5==1 then
				if Fix5Test==true then
					WAIT (ExtDI,{3,8},"ON")
					ExtDO(3,7,"ON")
					WAIT (ExtDI,{3,7},"ON")
					DELAY(0.5)
					WriteModbus(0x3105,"W",2)
    Fix5Finish=false
    iStep5=2					
				end	
			elseif iStep5==2 then
				if Fix5Finish==true then						
					ExtDO(3,7,"OFF")
					WAIT (ExtDI,{3,8},"ON")
					DELAY(0.5)					
					Testing5=false
					WriteModbus(0x3105,"W",1)
					Fix5Test=false
					iStep5 = 1
				else
    WriteModbus(0x3350,"W",1)
				end 
            end
		else
    Fix5Finish=false
			Fix5Test=false
			Fix5HPCB=false
			WriteModbus(0x3105,"W",1)
			iStep5 = 1
		end		 
end


function ThreadFix6()	
		Enable6=ReadModbus(0x3006,"W")
		if Enable6==1 then
			if iStep6==1 then
				if Fix6Test==true then
					WAIT (ExtDI,{3,9},"ON")
					ExtDO(3,8,"ON")
					WAIT (ExtDI,{3,8},"ON")
					DELAY(0.5)
					WriteModbus(0x3106,"W",2)
    Fix6Finish=false
    iStep6=2					
				end	
			elseif iStep6==2 then
				if Fix6Finish==true then						
					ExtDO(3,8,"OFF")
					WAIT (ExtDI,{3,9},"ON")
					DELAY(0.5)					
					Testing6=false
					WriteModbus(0x3106,"W",1)
					Fix6Test=false
					iStep6 = 1
				else
    WriteModbus(0x3360,"W",1)
				end 
            end
		else
    Fix6Finish=false
			Fix6Test=false
			Fix6HPCB=false
			WriteModbus(0x3106,"W",1)
			iStep6 = 1
		end		 
end


function ThreadFix7()	
		Enable7=ReadModbus(0x3007,"W")
		if Enable7==1 then
			if iStep7==1 then
				if Fix7Test==true then
					WAIT (ExtDI,{3,10},"ON")
					ExtDO(3,9,"ON")
					WAIT (ExtDI,{3,9},"ON")
					DELAY(0.5)
					WriteModbus(0x3107,"W",2)
    Fix7Finish=false
    iStep7=2					
				end	
			elseif iStep7==2 then
				if Fix7Finish==true then						
					ExtDO(3,9,"OFF")
					WAIT (ExtDI,{3,10},"ON")
					DELAY(0.5)					
					Testing7=false
					WriteModbus(0x3107,"W",1)
					Fix7Test=false
					iStep7 = 1
				else
    WriteModbus(0x3370,"W",1)
				end 
            end
		else
    Fix7Finish=false
			Fix7Test=false
			Fix7HPCB=false
			WriteModbus(0x3107,"W",1)
			iStep7 = 1
		end		 
end


function ThreadFix8()	
		Enable8=ReadModbus(0x3008,"W")
		if Enable8==1 then
			if iStep8==1 then
				if Fix8Test==true then
					WAIT (ExtDI,{3,11},"ON")
					ExtDO(3,10,"ON")
					WAIT (ExtDI,{3,10},"ON")
					DELAY(0.5)
					WriteModbus(0x3108,"W",2)
    Fix8Finish=false
    iStep8=2					
				end	
			elseif iStep8==2 then
				if Fix8Finish==true then						
					ExtDO(3,10,"OFF")
					WAIT (ExtDI,{3,11},"ON")
					DELAY(0.5)					
					Testing8=false
					WriteModbus(0x3108,"W",1)
					Fix8Test=false
					iStep8 = 1
				else
    WriteModbus(0x3380,"W",1)
				end 
            end
		else
    Fix8Finish=false
			Fix8Test=false
			Fix8HPCB=false
			WriteModbus(0x3108,"W",1)
			iStep8 = 1
		end		 
end


function ThreadFix9()	
		Enable9=ReadModbus(0x3009,"W")
		if Enable9==1 then
			if iStep9==1 then
				if Fix9Test==true then
					WAIT (ExtDI,{3,12},"ON")
					ExtDO(3,11,"ON")
					WAIT (ExtDI,{3,11},"ON")
					DELAY(0.5)
					WriteModbus(0x3109,"W",2)
    Fix9Finish=false
    iStep9=2					
				end	
			elseif iStep9==2 then
				if Fix9Finish==true then						
					ExtDO(3,11,"OFF")
					WAIT (ExtDI,{3,12},"ON")
					DELAY(0.5)					
					Testing9=false
					WriteModbus(0x3109,"W",1)
					Fix9Test=false
					iStep9 = 1
				else
    WriteModbus(0x3390,"W",1)
				end 
            end
		else
    Fix9Finish=false
			Fix9Test=false
			Fix9HPCB=false
			WriteModbus(0x3109,"W",1)
			iStep9 = 1
		end		 
end


function ThreadFix10()	
		Enable10=ReadModbus(0x300A,"W")
		if Enable10==1 then
			if iStep10==1 then
				if Fix10Test==true then
					WAIT (ExtDI,{3,13},"ON")
					ExtDO(3,12,"ON")
					WAIT (ExtDI,{3,12},"ON")
					DELAY(0.5)
					WriteModbus(0x310A,"W",2)
    Fix10Finish=false
    iStep10=2					
				end	
			elseif iStep10==2 then
				if Fix10Finish==true then						
					ExtDO(3,12,"OFF")
					WAIT (ExtDI,{3,13},"ON")
					DELAY(0.5)					
					Testing10=false
					WriteModbus(0x310A,"W",1)
					Fix10Test=false
					iStep10 = 1
				else
    WriteModbus(0x33A0,"W",1)
				end 
            end
		else
    Fix10Finish=false
			Fix10Test=false
			Fix10HPCB=false
			WriteModbus(0x310A,"W",1)
			iStep10 = 1
		end		 
end


function ThreadFix11()	
		Enable11=ReadModbus(0x300B,"W")
		if Enable11==1 then
			if iStep11==1 then
				if Fix11Test==true then
					WAIT (ExtDI,{3,14},"ON")
					ExtDO(3,13,"ON")
					WAIT (ExtDI,{3,13},"ON")
					DELAY(0.5)
					WriteModbus(0x310B,"W",2)
    Fix11Finish=false
    iStep11=2					
				end	
			elseif iStep11==2 then
				if Fix11Finish==true then						
					ExtDO(3,13,"OFF")
					WAIT (ExtDI,{3,14},"ON")
					DELAY(0.5)					
					Testing11=false
					WriteModbus(0x310B,"W",1)
					Fix11Test=false
					iStep11 = 1
				else
    WriteModbus(0x33B0,"W",1)
				end 
            end
		else
    Fix11Finish=false
			Fix11Test=false
			Fix11HPCB=false
			WriteModbus(0x310B,"W",1)
			iStep11 = 1
		end		 
end

function Initail()
	
	--HomeAuto()
	Speed(ReadModbus(0x3FFF,"W"))
	
	IStep = 99
	
	--SpeedHigh()
	--DO("Gripper1","OFF")
	--DO("Gripper2","OFF")
	WAIT(DI,9,"ON") --smc alarm
	ExtDO(3,9,"OFF")
	ExtDO(3,10,"OFF")
	ExtDO(3,11,"OFF")
	ExtDO(3,12,"OFF")
	ExtDO(3,13,"OFF")
	ExtDO(3,14,"OFF") --home
	ExtDO(3,15,"OFF") --drive
	ExtDO(3,16,"OFF") --reset
	DELAY(1)
	ExtDO(3,16,"ON") --reset
	DELAY(0.5)
	ExtDO(3,16,"OFF") 
	DELAY(0.5)
	ExtDO(3,14,"ON") --home
	--WAIT(DI,8,"ON") --smc busy
	DELAY(0.5)
	ExtDO(3,14,"OFF")
	
	WriteModbus(0x3333,"W",1)
	
    
	Status1=ReadModbus(0x3101,"W")
	Enable1=ReadModbus(0x3001,"W")
	if Status1==2 then        
		Fix1HPCB=true
        Fix1Finish=false
        Fix1Test=true
        iStep1 = 2
	elseif Status1==3 then		
		Fix1HPCB=true
        Fix1Finish=true
        Fix1Test=false        
        iStep1 = 3
        print("1Err_0")
	else        
		Fix1HPCB=false
        Fix1Finish=false
        Fix1Test=false
        iStep1 = 1
	end


	Status2=ReadModbus(0x3102,"W")
	Enable2=ReadModbus(0x3002,"W")
	if Status2==2 then        
		Fix2HPCB=true
        Fix2Finish=false
        Fix2Test=true
        iStep2 = 2
	elseif Status2==3 then		
		Fix2HPCB=true
        Fix2Finish=true
        Fix2Test=false        
        iStep2 = 3
        print("2Err_0")
	else        
		Fix2HPCB=false
        Fix2Finish=false
        Fix2Test=false
        iStep2 = 1
	end


	Status3=ReadModbus(0x3103,"W")
	Enable3=ReadModbus(0x3003,"W")
	if Status3==2 then        
		Fix3HPCB=true
        Fix3Finish=false
        Fix3Test=true
        iStep3 = 2
	elseif Status3==3 then		
		Fix3HPCB=true
        Fix3Finish=true
        Fix3Test=false        
        iStep3 = 3
        print("3Err_0")
	else        
		Fix3HPCB=false
        Fix3Finish=false
        Fix3Test=false
        iStep3 = 1
	end


	Status4=ReadModbus(0x3104,"W")
	Enable4=ReadModbus(0x3004,"W")
	if Status4==2 then        
		Fix4HPCB=true
        Fix4Finish=false
        Fix4Test=true
        iStep4 = 2
	elseif Status4==3 then		
		Fix4HPCB=true
        Fix4Finish=true
        Fix4Test=false        
        iStep4 = 3
        print("4Err_0")
	else        
		Fix4HPCB=false
        Fix4Finish=false
        Fix4Test=false
        iStep4 = 1
	end


	Status5=ReadModbus(0x3105,"W")
	Enable5=ReadModbus(0x3005,"W")
	if Status5==2 then        
		Fix5HPCB=true
        Fix5Finish=false
        Fix5Test=true
        iStep5 = 2
	elseif Status5==3 then		
		Fix5HPCB=true
        Fix5Finish=true
        Fix5Test=false        
        iStep5 = 3
        print("5Err_0")
	else        
		Fix5HPCB=false
        Fix5Finish=false
        Fix5Test=false
        iStep5 = 1
	end


	Status6=ReadModbus(0x3106,"W")
	Enable6=ReadModbus(0x3006,"W")
	if Status6==2 then        
		Fix6HPCB=true
        Fix6Finish=false
        Fix6Test=true
        iStep6 = 2
	elseif Status6==3 then		
		Fix6HPCB=true
        Fix6Finish=true
        Fix6Test=false        
        iStep6 = 3
        print("6Err_0")
	else        
		Fix6HPCB=false
        Fix6Finish=false
        Fix6Test=false
        iStep6 = 1
	end


	Status7=ReadModbus(0x3107,"W")
	Enable7=ReadModbus(0x3007,"W")
	if Status7==2 then        
		Fix7HPCB=true
        Fix7Finish=false
        Fix7Test=true
        iStep7 = 2
	elseif Status7==3 then		
		Fix7HPCB=true
        Fix7Finish=true
        Fix7Test=false        
        iStep7 = 3
        print("7Err_0")
	else        
		Fix7HPCB=false
        Fix7Finish=false
        Fix7Test=false
        iStep7 = 1
	end


	Status8=ReadModbus(0x3108,"W")
	Enable8=ReadModbus(0x3008,"W")
	if Status8==2 then        
		Fix8HPCB=true
        Fix8Finish=false
        Fix8Test=true
        iStep8 = 2
	elseif Status8==3 then		
		Fix8HPCB=true
        Fix8Finish=true
        Fix8Test=false        
        iStep8 = 3
        print("8Err_0")
	else        
		Fix8HPCB=false
        Fix8Finish=false
        Fix8Test=false
        iStep8 = 1
	end


	Status9=ReadModbus(0x3109,"W")
	Enable9=ReadModbus(0x3009,"W")
	if Status9==2 then        
		Fix9HPCB=true
        Fix9Finish=false
        Fix9Test=true
        iStep9 = 2
	elseif Status9==3 then		
		Fix9HPCB=true
        Fix9Finish=true
        Fix9Test=false        
        iStep9 = 3
        print("9Err_0")
	else        
		Fix9HPCB=false
        Fix9Finish=false
        Fix9Test=false
        iStep9 = 1
	end


	Status10=ReadModbus(0x310A,"W")
	Enable10=ReadModbus(0x300A,"W")
	if Status10==2 then        
		Fix10HPCB=true
        Fix10Finish=false
        Fix10Test=true
        iStep10 = 2
	elseif Status10==3 then		
		Fix10HPCB=true
        Fix10Finish=true
        Fix10Test=false        
        iStep10 = 3
        print("10Err_0")
	else        
		Fix10HPCB=false
        Fix10Finish=false
        Fix10Test=false
        iStep10 = 1
	end


	Status11=ReadModbus(0x310B,"W")
	Enable11=ReadModbus(0x300B,"W")
	if Status11==2 then        
		Fix11HPCB=true
        Fix11Finish=false
        Fix11Test=true
        iStep11 = 2
	elseif Status11==3 then		
		Fix11HPCB=true
        Fix11Finish=true
        Fix11Test=false        
        iStep11 = 3
        print("11Err_0")
	else        
		Fix11HPCB=false
        Fix11Finish=false
        Fix11Test=false
        iStep11 = 1
	end

	
end 

function Main()	
	Initail()
	if DO(8)==ON then
		--PlaceFAIL()
		PlaceFailGripper(2)
	end
	if DO(7)==ON then
		--PlaceScanFAIL()
		PlaceFailGripper(1)	
	end
	DO("TowerLightG","ON")
	while true do
        -- Main loop logic is complex and station-specific,
        -- It is kept here as a reference and should be edited manually in the template.
		if IStep==99 then						
			ppp=ReadModbus(0x3FFE,"W")
			Status9=ReadModbus(0x3109,"W")
            Status10=ReadModbus(0x310A,"W")
            if ppp > 0 and DI(12)==OFF and DI(13)==OFF and (ExtDI(3,1)==ON or Fix9HPCB==false)  and (ExtDI(3,3)==ON or Fix10HPCB==false) then
            	tt = 0
            	-- PickPASS2() -- This function is not fully defined in the provided snippet
                IStep = 99                
            elseif DI(14)==ON  then
                tt = 0
                c1 = 0
			::TryScan::
				WriteModbus(0x3140,"W",1)
				TcpIpScan()
				DELAY(1)
				print("2 = ",sn1)
				if sn1 ~= nil and #sn1 == 15 and sn3 ~= sn1 and c1> 0  then
					sn3 = sn1
                    PickToCVIN()                    
                    testCam = ReadModbus(0x3333,"W")
                    testCam = 1
                    sn2 = sn1
                    IStep=9004
                elseif sn1 == "NO"  then   
                	PickToCVIN()
                	PlaceFAIL3()                	                   
                    IStep = 99 
                elseif sn1 == "ng" or  sn1 == "NG" or c1 > 5 then   
                	PickToCVIN()
                	PlaceFAIL3()               	                   
                    IStep = 99 
                elseif c1 < 6 then
                	c1 = c1 + 1
                	goto TryScan                                   
				else                    
                    IStep = 99
				end
            else
                MovP("SBuffer")
                IStep=8000 
			end 
		elseif IStep==88 then	
			if DI(21)==ON   then
				tt = 0	
				-- PickToCamera() -- This function is not fully defined in the provided snippet
				IStep=9004
			else
                MovP("SBuffer")
                IStep=99
			end		
		elseif IStep==9000 then-- FINISH
			
elseif Fix1Test==false and Fix1Finish==true and Fix1HPCB==true and ExtDI(3,2)==ON and DI(18)==ON and Enable1==1  then
    tt = 0
    PickToFix1()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99


elseif Fix2Test==false and Fix2Finish==true and Fix2HPCB==true and ExtDI(3,3)==ON and DI(18)==ON and Enable2==1  then
    tt = 0
    PickToFix2()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99


elseif Fix3Test==false and Fix3Finish==true and Fix3HPCB==true and ExtDI(3,5)==ON and DI(18)==ON and Enable3==1  then
    tt = 0
    PickToFix3()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99


elseif Fix4Test==false and Fix4Finish==true and Fix4HPCB==true and ExtDI(3,7)==ON and DI(18)==ON and Enable4==1  then
    tt = 0
    PickToFix4()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99


elseif Fix5Test==false and Fix5Finish==true and Fix5HPCB==true and ExtDI(3,8)==ON and DI(18)==ON and Enable5==1  then
    tt = 0
    PickToFix5()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99


elseif Fix6Test==false and Fix6Finish==true and Fix6HPCB==true and ExtDI(3,9)==ON and DI(18)==ON and Enable6==1  then
    tt = 0
    PickToFix6()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99


elseif Fix7Test==false and Fix7Finish==true and Fix7HPCB==true and ExtDI(3,10)==ON and DI(18)==ON and Enable7==1  then
    tt = 0
    PickToFix7()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99


elseif Fix8Test==false and Fix8Finish==true and Fix8HPCB==true and ExtDI(3,11)==ON and DI(18)==ON and Enable8==1  then
    tt = 0
    PickToFix8()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99


elseif Fix9Test==false and Fix9Finish==true and Fix9HPCB==true and ExtDI(3,12)==ON and DI(18)==ON and Enable9==1  then
    tt = 0
    PickToFix9()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99


elseif Fix10Test==false and Fix10Finish==true and Fix10HPCB==true and ExtDI(3,13)==ON and DI(18)==ON and Enable10==1  then
    tt = 0
    PickToFix10()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99


elseif Fix11Test==false and Fix11Finish==true and Fix11HPCB==true and ExtDI(3,14)==ON and DI(18)==ON and Enable11==1  then
    tt = 0
    PickToFix11()
    -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
    IStep = 99

        else
            -- Other IStep logic...
            DELAY(0.1)
		end
		
		-- Threaded tasks for each fixture
		ThreadFix1()
		ThreadFix2()
		ThreadFix3()
		ThreadFix4()
		ThreadFix5()
		ThreadFix6()
		ThreadFix7()
		ThreadFix8()
		ThreadFix9()
		ThreadFix10()
		ThreadFix11()
		
		DELAY(0.05)
	end
end