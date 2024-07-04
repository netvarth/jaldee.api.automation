*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        ITEM
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

${item1}  ITEM1
${item2}  ITEM2
${item3}  ITEM3
${item4}  ITEM4
${SERVICE1}   SERVICE1
${SERVICE2}    SERVICE2
${queue1}  queue1
${queue2}   queue2
${service_duration}   2
${parallel}           1

*** Test Cases ***


JD-TC-Delete Item-UH1

    [Documentation]   Consumer check to delete item
    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-Delete Item-1

#     [Documentation]  Provider check to delete item
#     clear_Item  ${PUSERNAME14}
#     clear_service       ${PUSERNAME225}
#     clear_service       ${PUSERNAME5}
#     clear_Item   ${PUSERNAME5}
#     clear_Item  ${PUSERNAME225}  
#     clear_queue   ${PUSERNAME5}   
#     clear_queue   ${PUSERNAME225}   
#     clear_location   ${PUSERNAME225}   
#     clear_location   ${PUSERNAME5}
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}   ${amount1}    ${bool[0]} 
#     Log   ${resp}  
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id}  ${resp.json()}
#     ${amount2}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item2}   ${des}   ${description}  ${amount2}   ${bool[0]} 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${id1}  ${resp.json()}
    
#     ${resp}=   Get Items 
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${le}=  Get Length  ${resp.json()}
#     Should Be Equal As Strings  ${le}  2
#     Verify Response List  ${resp}   0   itemId=${id}   displayName=${item1}   shortDesc=${des}     displayDesc=${description}   price=${amount1}   taxable=${bool[0]}    status=${status[0]}
#     Verify Response List  ${resp}   1   itemId=${id1}    displayName=${item2}   shortDesc=${des}     displayDesc=${description}   price=${amount2}   taxable=${bool[0]}    status=${status[0]}
#     ${resp}=   Delete Item   ${id}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Get Items 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${le}=  Get Length  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${le}  1
#     Verify Response List  ${resp}  0    itemId=${id1}    displayName=${item2}   shortDesc=${des}     displayDesc=${description}     price=${amount2}   taxable=${bool[0]}    status=${status[0]}


# JD-TC-Delete Item-UH1

#     [Documentation]   Consumer check to delete item
#     ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Delete Item     ${id1}  
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"   

# JD-TC-Delete Item-UH2

#     [Documentation]   delete item  without login
#     ${resp}=   Delete Item     ${id1}  
#     Should Be Equal As Strings  ${resp.status_code}  419    
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"  

# JD-TC-Delete Item-UH3

#     [Documentation]   Provider check to delete item  with another provider's item id
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${amount3}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item3}  ${des}   ${description}  ${amount3}  ${bool[0]} 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id3}  ${resp.json()}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=   Delete Item   ${id3}
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

# JD-TC-Delete Item -UH4

#     [Documentation]   provider check to delete item  with invalid item id
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=   Delete Item   0
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEM_FOUND}"



# JD-TC- Delete Item -UH5

#     [Documentation]   try to delete item when item on unsettled bill
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${notifytype}    Random Element     ['none','pushMsg','email']


#     ${billable_domains}=  get_billable_domain
#     Set Test Variable  ${domains}  ${billable_domains[0]}
#     Set Test Variable  ${sub_domains}   ${billable_domains[1]}
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+45220
#     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
#     ${licid}=  get_highest_license_pkg
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains[1]}  ${sub_domains[1]}  ${PUSERPH0}  ${licid[0]}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 

#    # ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200


#     ${DAY}=  db.get_date_by_timezone  ${tz}   
#     Set Suite Variable  ${DAY} 
#     ${tomorrow}=  db.add_timezone_date  ${tz}  1     
#     Set Suite Variable  ${tomorrow} 
#     ${list}=  Create List  1  2  3  4  5  6  7
#     Set Suite Variable  ${list}
    

#     # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
#     ${eTime}=  add_timezone_time  ${tz}  0  30  
#     ${city}=   FakerLibrary.state
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}    Random Element     ${parkingType} 
#     ${24hours}    Random Element    ['True','False']
#     ${url}=   FakerLibrary.url
#     ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}   200



#     ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}   ${amount1}   ${bool[1]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id}  ${resp.json()}
    
#     ${GST_num}  ${pan_num}=  db.Generate_gst_number  ${Container_id}
#     ${resp}=  Update Tax Percentage  18   ${GST_num} 
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${resp}=  Enable Tax
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${resp}=   ProviderLogout
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     # ${resp}=  Get Service   name-eq=${SERVICE2}
#     # Log  ${resp.json()}
#     # Should Be Equal As Strings  ${resp.status_code}  200  
   
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable  ${DAY1}  ${DAY1}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     Set Suite Variable  ${list}  ${list}
#     ${ph1}=  Evaluate  ${PUSERNAME}+1000000000
#     ${ph2}=  Evaluate  ${PUSERNAME}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERPH0}.${test_mail}  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address

#     #${resp}=  Create Business Profile  ${bs}  ${bs} Desc   ${companySuffix}  ${city}   ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
#     #Log  ${resp.json()}
#     #Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Update Business Profile with schedule  ${bs}  ${bs} Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Enable Waitlist
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${firstname}=  FakerLibrary.first_name
#      ${lastname}=  FakerLibrary.last_name
#      Set Test Variable  ${email2}  ${firstname}${C_Email}.${test_mail}
#      ${gender}=  Random Element    ${Genderlist}
#      ${dob}=  FakerLibrary.Date
#      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME1}  ${EMPTY}
#      Set Suite Variable  ${cid1}  ${resp.json()}
#      Log  ${resp.json()}
#      Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Locations
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

#     ${P1SERVICE1}=    FakerLibrary.word
#     ${desc}=   FakerLibrary.sentence

#     ${min_pre}=   Random Int   min=10   max=50
#     ${Total}=   Random Int   min=100   max=500
#     ${min_pre}=  Convert To Number  ${min_pre}  1
#     ${Total1}=  Convert To Number  ${Total}  1 
#     Set Suite Variable   ${Total}   ${Total1}


#     ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  none  ${min_pre}  ${Total}  ${bool[1]}  ${bool[1]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${p1_sid1}  ${resp.json()}
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${queue2}=    FakerLibrary.word
#     ${capacity}=  FakerLibrary.Numerify  %%
#     ${sTime1}=  add_time  2   45
#     ${eTime1}=  add_time   3   00
#     ${resp}=  Create Queue  ${queue2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${p1_qid1}  ${resp.json()}


#     # ${resp}=  Create Sample Queue

#     # Set Suite Variable  ${sid1}  ${resp['service_id']}
#     # Set Suite Variable  ${qid}   ${resp['queue_id']}
#     # Set Suite Variable  ${lid}   ${resp['location_id']} 
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${dob}=  FakerLibrary.Date
#     ${ph2}=  Evaluate  ${PUSERNAME5}+61005
#     Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
#     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${Genderlist[0]}  ${dob}  ${ph2}   ${EMPTY}
#     Set Suite Variable  ${cid}  ${resp.json()}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
      
#     #${resp}=  Add To Waitlist  ${cid}  ${sid1}   ${qid}   ${DAY1}  hi  ${bool[1]}   0

#     ${resp}=  Add To Waitlist  ${cid}  ${p1_sid1}  ${p1_qid1}  ${DAY1}  hi  ${bool[1]}  ${cid}

#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${json}=  evaluate    json.loads('''${resp.content}''')    json
#     ${wid}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${wid}  ${wid[0]}
#     ${resp}=  Get Bill By UUId  ${wid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${item}=  Item Bill   ${des}   ${id}  1
#     ${resp}=  Update Bill   ${wid}  addItem   ${item}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Delete Item   ${id}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${resp}=   Get Item By Id   ${id}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_ITEM_ID}" 


# JD-TC- Delete Item -UH6

#     [Documentation]   try to delete item that is on setled bill(When item setteled on bill,item can  delete, just change its status as INACTVE)

#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${notifytype}    Random Element     ['none','pushMsg','email']
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME225}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${amount4}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item4}  ${des}  ${description}  ${amount4}  ${bool[1]}  
#     Log  ${resp.json()}         
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${itemId1}  ${resp.json()}
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${dob}=  FakerLibrary.Date
#     ${ph2}=  Evaluate  ${PUSERNAME225}+71015
#     Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
#     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${Genderlist[0]}  ${dob}  ${CUSERNAME5}   ${EMPTY}
#     Set Suite Variable  ${cid1}  ${resp.json()}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200


#     ${resp}=  Encrypted Provider Login  ${PUSERNAME225}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=   Get Service   name-eq=${SERVICE2}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200  
   
#     ${resp}=  Create Sample Queue 
    
#     Set Suite Variable  ${s_id}  ${resp['service_id']}
#     Set Suite Variable  ${qid}   ${resp['queue_id']}
#     Set Suite Variable  ${lid}   ${resp['location_id']}    
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${resp}=  Add To Waitlist  ${cid1}   ${s_id}   ${qid}  ${DAY1}  hi  ${bool[1]}   ${cid1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${json}=  evaluate    json.loads('''${resp.content}''')    json
#     ${wid}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${wid}  ${wid[0]}
#     ${resp}=  Get Bill By UUId  ${wid}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${item}=  Item Bill  my Item  ${itemId1}  1
#     ${resp}=  Update Bill   ${wid}  addItem   ${item}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Bill By UUId  ${wid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable   ${amountdue}   ${resp.json()['amountDue']}
#     ${resp}=  Accept Payment  ${wid}  cash   ${amountdue}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Settl Bill  ${wid}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Delete Item   ${itemId1}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Get Item By Id   ${itemId1}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_ITEM_ID}" 