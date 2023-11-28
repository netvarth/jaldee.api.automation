*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Customer
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***

JD-TC-Get Terminologies -1
       [Documentation]   Provider check to Get Terminologies without login
       ${resp}=  Get Terminologies  healthCare  physiciansSurgeons
       Should Be Equal As Strings    ${resp.status_code}   200        
       Verify Response  ${resp}  customer=patient  provider=doctor   waitlist=Check-In  waitlisted=checkedin  arrived=arrived  start=start  started=started  cancelled=cancelled  done=done

JD-TC-Get Terminologies -2
       [Documentation]   Provider check to Get Terminologies
       ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Terminologies  healthCare  physiciansSurgeons
       Should Be Equal As Strings    ${resp.status_code}   200 
       Verify Response  ${resp}  customer=patient  provider=doctor    waitlist=Check-In  waitlisted=checkedin  arrived=arrived  start=start  started=started  cancelled=cancelled  done=done
                  
JD-TC-Get Terminologies -3
       [Documentation]   Provider check to Get Terminologies
       ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Terminologies  personalCare  beautyCare
       Should Be Equal As Strings    ${resp.status_code}   200 
       Verify Response  ${resp}  customer=customer  provider=service provider    waitlisted=checkedin  arrived=arrived  start=start  started=started  cancelled=cancelled  done=done

JD-TC-Get Terminologies -4
       [Documentation]   Provider check to Get Terminologies consumer
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Terminologies  foodJoints  restaurants
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200        
       Verify Response  ${resp}  customer=customer  provider=restaurant   waitlist=Check-In  waitlisted=checkedin  arrived=arrived  start=start  started=started  cancelled=cancelled  done=done
    
    
JD-TC-Get Terminologies -UH1
       [Documentation]   Provider check to Get Terminologies  Domain and sub domain miss match
       ${resp}=  Get Terminologies  personalCare  physiciansSurgeons
       Should Be Equal As Strings    ${resp.status_code}   422 
       Should Be Equal As Strings  "${resp.json()}"     "${INVALID_SUB_SECTOR}"
             
