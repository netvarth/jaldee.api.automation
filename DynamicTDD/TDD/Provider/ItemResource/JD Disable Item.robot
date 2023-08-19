*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags       ITEM
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${item1}   ITEM1
${item2}   ITEM2
${item5}   ITEM5
${SERVICE1}  SERVICE1
${SERVICE2}  SERVICE2
${queue1}  queue1
@{service_duration}  10  20  30   40   50
*** Test Cases ***

JD-TC-Disable Item-UH1

    [Documentation]   Disable already disabled item
    ${resp}=  ProviderLogin  ${PUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

# JD-TC-Disable Item-1

#     [Documentation]  Provider Create item and try for Disable
#     clear_Item  ${PUSERNAME18}
#     clear_service   ${PUSERNAME18}
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  ProviderLogin  ${PUSERNAME18}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     Set Suite Variable    ${amount1}
    
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount1}  ${bool[0]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${id}  ${resp.json()}
   
#     ${resp}=   Get Item By Id  ${id} 
#     Verify Response  ${resp}  displayName=${item1}  displayDesc=${description}   shortDesc=${des}   status=ACTIVE  price=${amount1}    taxable=${bool[0]} 
#     ${resp}=  Disable Item  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Item By Id  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${resp}=   Get Item By Id  ${id} 
#     Verify Response   ${resp}  displayName=${item1}   shortDesc=${des}   displayDesc=${description}   status=INACTIVE  price=${amount1}  taxable=${bool[0]} 

# JD-TC-Disable Item-UH1

#     [Documentation]   Disable already disabled item
#     ${resp}=  ProviderLogin  ${PUSERNAME18}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Disable Item  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${ITEM_ALREADY_DISABLED}"

# JD-TC-Disable Item-UH2

#     [Documentation]   Disable item without login
#     ${resp}=  Disable Item  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  419
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"      

# JD-TC-Disable Item-UH3

#     [Documentation]  Consumer try to Disable an Item
#     ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Disable Item  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

# JD-TC-Disable Item-UH4

#     [Documentation]  try to Disabled another providers item
#     ${resp}=  ProviderLogin  ${PUSERNAME3}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Disable Item  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

# JD-TC-Disable Item-2

#     [Documentation]  try to Disable item when item on unsetled bill
#     Comment  try to Disable item when item is removed from bill by updation 
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${min_pre}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
#     ${Total}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
#     ${resp}=  ProviderLogin  ${PUSERNAME18}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${amount5}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
    
#     ${resp}=  Create Item   ${item5}  ${des}   ${description}  ${amount5}  ${bool[0]}   
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${id}  ${resp.json()}
   
#     ${GST_num}  ${pan_num}=  db.Generate_gst_number  ${Container_id}
#     ${resp}=  Update Tax Percentage  18   ${GST_num} 
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${resp}=  Enable Tax
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${gender}=  Random Element    ${Genderlist}
#     ${dob}=  FakerLibrary.Date
#     ${ph2}=  Evaluate  ${PUSERNAME18}+71016
#     Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.ynwtest@netvarth.com
#     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME4}   ${EMPTY}
#     Set Suite Variable  ${cid}  ${resp.json()}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
   
#     ${DAY1}=  get_date
#     ${resp}=  Create Service  ${SERVICE1}   ${description}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200     
#     Set Test Variable  ${sid1}  ${resp.json()}     
#     ${resp}=  Create Service  ${SERVICE2}   ${description}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200     
#     Set Suite Variable  ${sid2}  ${resp.json()}     
#     ${resp}=  Get Locations
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
#     ${list}=  Create List   1  2  3  4  5  6  7
#     ${sTime}=  get_time  
#     ${eTime}=  add_time   4   00
#     ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sid1}   ${sid2}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${qid1}  ${resp.json()}
#     ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY1}  hi  True  ${cid}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${json}=  evaluate    json.loads('''${resp.content}''')    json
#     ${wid}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${wid}  ${wid[0]}
#     ${resp}=  Get Bill By UUId  ${wid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${item}=  Item Bill   ${des}    ${id}   1
#     ${resp}=  Update Bill   ${wid}  addItem   ${item}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Bill By UUId  ${wid}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}   ${id}  
#     Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${amount5}   
#     ${resp}=   Disable Item   ${id}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Get Item By Id  ${id} 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  displayName=${item5}   displayDesc=${description}   shortDesc=${des}  status=${status[1]}  price=${amount5}     taxable=${bool[0]}


# JD-TC- Disable Item -UH5

#     [Documentation]   try to Disable item that is on setled bill(When item setteled on bill,item can not Disable, just change its status as INACTVE)
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${notifytype}    Random Element     ['none','pushMsg','email']
#     ${notify}    Random Element     ['True','False']
#     ${resp}=  ProviderLogin  ${PUSERNAME18}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${amount2}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
   
#     ${resp}=  Create Item   ${item2}  ${des}   ${description}  ${amount2}   ${bool[0]}  
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id}  ${resp.json()}
    
#     ${DAY1}=  get_date
#     ${resp}=  Add To Waitlist  ${cid}  ${sid2}  ${qid1}  ${DAY1}  hi  True  ${cid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${json}=  evaluate    json.loads('''${resp.content}''')    json
#     ${wid}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${wid}  ${wid[0]}
#     ${resp}=  Get Bill By UUId  ${wid}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${item}=  Item Bill  ${des}   ${id}   1
#     ${resp}=  Update Bill   ${wid}  addItem   ${item}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${resp}=  Get Bill By UUId  ${wid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable   ${amountdue}   ${resp.json()['amountDue']}
#     ${resp}=  Accept Payment  ${wid}  cash   ${amountdue} 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Settl Bill  ${wid}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Disable Item    ${id}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Get Item By Id    ${id}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response   ${resp}   itemId=${id}    displayName=${item2}   shortDesc=${des}     displayDesc=${description}    price=${amount2}   taxable=${bool[0]}   status=${status[1]}