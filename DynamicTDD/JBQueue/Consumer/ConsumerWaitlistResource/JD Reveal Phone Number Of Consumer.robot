*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}   FacialBodyABCD
${SERVICE2}   MakeupHairEFGHI
${SERVICE3}   Makeup
${SERVICE4}   Bleach
${self}       0

*** Test Cases ***
JD-TC-Reveal Phone Number of Consumer-1
	[Documentation]   Set Reveal phone number of consumer as true 
	
    clear_queue    ${PUSERNAME13}
    clear_service  ${PUSERNAME13}
    ${resp}=  ProviderLogin  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME13}
    Set Suite Variable  ${pid} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${DAY}=  get_date  
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()[0]['id']}
    ${desc}=  FakerLibrary.word
    ${ser_durtn}=   Random Int  min=2   max=10
    ${total_amount}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifyType[1]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${qname}=   FakerLibrary.word
    ${sTime1}=  subtract_time   1  00
    ${eTime1}=   add_time    5   00
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${qname}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}   ${parallel}    ${capacity}   ${lid1}  ${sId_1}  
    Set Suite Variable  ${q1_l1}  ${resp.json()}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${resp}=  Add Favourite Provider  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   3s
    ${resp}=  List Favourite Provider
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  id=${pid} 
    ${cid}=  get_id  ${CUSERNAME8}
    ${cnote}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_l1}  ${DAY}  ${sId_1}  ${cnote}  ${bool[0]}   ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Reveal Phone Number  ${pid}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Logout   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME8}
   
	comment   Set Reveal phone number of consumer as false 

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${phne}=  Convert To String   ${CUSERNAME8}
    ${ph}=   Get Substring	 ${phne}   6   10 
    ${phone}=   Set Variable   ******${ph} 
    ${resp}=  Reveal Phone Number  ${pid}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Consumer Logout   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}   ${phone}

JD-TC-Reveal Phone Number of Consumer-2
	[Documentation]   Set Reveal phone number of consumer as false
    
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${resp}=  Add Favourite Provider  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  List Favourite Provider
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  id=${pid} 
    ${resp}=  Reveal Phone Number  ${pid}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${PUSERNAME13}
    Set Test Variable  ${pid1} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   
    
    clear_customer   ${PUSERNAME13}

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${phne}=  Convert To String   ${CUSERNAME7}
    ${ph}=   Get Substring	 ${phne}   6   10 
    ${phone}=   Set Variable   ******${ph} 
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid2}  ${resp.json()[0]['id']}
    ${desc}=  FakerLibrary.word
    ${ser_durtn}=   Random Int  min=2   max=10
    ${total_amount}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifyType[1]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${qname1}=   FakerLibrary.word
    ${sTime1}=  subtract_time   1  00
    ${eTime1}=   add_time    5   00
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${qname1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}    ${parallel}   ${capacity}   ${lid2}  ${sId_2}  
    Set Suite Variable  ${q1_l2}  ${resp.json()}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${sId_2}  ${q1_l2}  ${DAY}  ${cnote}  ${bool[0]}  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}   	${phone}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Reveal Phone Number  ${pid1}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME7}

    ${desc}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Reveal Phone Number  ${pid1}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}   ${phone}
          
JD-TC-Reveal Phone Number of Consumer-UH1 
	[Documentation]  Set Reveal phone number of consumer by login of a provider   
    
    ${resp}=  ProviderLogin  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid3}=  get_acc_id  ${PUSERNAME13}
    Set Test Variable  ${pid3} 
    ${resp}=  Reveal Phone Number  ${pid3}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ACCESS_TO_URL}"  
    
JD-TC-Reveal Phone Number of Consumer-UH2
	[Documentation]  Set Reveal phone number of consumer without login      
    
    ${resp}=  Reveal Phone Number  ${pid}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
    
JD-TC-Reveal Phone Number of Consumer-UH3
	[Documentation]  Set Reveal phone number of consumer by another provider's account id  
    clear waitlist   ${PUSERNAME13}
    ${resp}=  Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid4}=  get_acc_id  ${PUSERNAME13}
    Set Test Variable  ${pid4}  ${pid4}
    ${pid5}=  get_acc_id  ${PUSERNAME5}
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD} 
    ${cid4}=  get_id  ${CUSERNAME7}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${cnote}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid4}  ${q1_l2}  ${DAY}  ${sId_2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Reveal Phone Number  ${pid5}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"     "${FAVOURITE_PROVIDER_NOT_EXIST}"