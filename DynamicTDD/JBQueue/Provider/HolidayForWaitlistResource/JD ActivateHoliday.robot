*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Holiday
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${self}   0  
${service_duration}   2
${parallel}           1
${digits}       0123456789


*** Test Cases ***

JD-TC-ActivateHoliday-1
    [Documentation]   Take waitlist and then create a  holiday for the 3 days here activate holiday status is true and try to check waitliststatus (no waiting time)

    clear_service    ${PUSERNAME35}
    clear_location   ${PUSERNAME35}
    clear_queue      ${PUSERNAME35}
    clear_customer   ${PUSERNAME35}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME35}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME35}

    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Change License Package  ${pkgid[0]}
    Should Be Equal As Strings    ${resp.status_code}   200
 
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   2

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]} 

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]} 

    ${resp}=   Activate Holiday  ${boolean[1]}  ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 
    sleep   04s
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}

   
JD-TC-ActivateHoliday-2
    [Documentation]   Take waitlist and then create a  holiday for the 3 days here activate holiday status is false and try to check waitliststatus (no waiting time)

    clear_service    ${PUSERNAME35}
    clear_location   ${PUSERNAME35}
    clear_queue      ${PUSERNAME35}
    clear_customer   ${PUSERNAME35}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME35}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME35}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}   
    ${CUR_DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY1}

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY1}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY1}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY1}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   2

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY1}  waitlistStatus=${wl_status[1]} 

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY1}  waitlistStatus=${wl_status[1]} 

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY1}  waitlistStatus=${wl_status[1]} 

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY1}  waitlistStatus=${wl_status[1]} 

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}

JD-TC-ActivateHoliday-3
    [Documentation]  Taking future waitlist from consumer side for a prepayment service ,then creating a holiday and activate status is true then check waitlist status then deleting that holiday

    clear_location   ${PUSERNAME158}
    clear_service    ${PUSERNAME158}
    clear_queue     ${PUSERNAME158}
    clear_customer   ${PUSERNAME158}

    ${pid}=  get_acc_id  ${PUSERNAME158}
    Set Suite Variable  ${pid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME158}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
   
    # ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    # ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${resp}=  Enable Tax
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${ifsc_code}=   db.Generate_ifsc_code
    # ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    # ${bank_name}=  FakerLibrary.company
    # ${name}=  FakerLibrary.name
    # ${branch}=   db.get_place
    # ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME158}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  payuVerify  ${pid}
    # Log  ${resp}
    # ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME158}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${min_pre}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable   ${min_pre}   
    ${pre_float}=  twodigitfloat  ${min_pre}
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot}   ${Tot1}

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Tot}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME4}
    Set Suite Variable   ${cid1}

    ${fday}=  db.add_timezone_date  ${tz}  2       
    ${msg}=  FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${fday}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}  2
    ${balamount1}=  Evaluate  ${totalamt}-${min_pre}
    ${balamount}=  Convert To Number  ${balamount1}  2

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${min_pre}  ${bool[1]}  ${cwid}  ${pid}  ${purpose[0]}  ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME158}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre}  amountDue=${balamount}    totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}   waitlistStatus=${wl_status[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME158}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${Last_Day}  ${EMPTY}  ${sTime}  ${eTime}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId5}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   1

    ${resp}=  Get Waitlist By Id  ${cwid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${fday}  waitlistStatus=${wl_status[0]} 
   
    ${resp}=   Activate Holiday  ${boolean[1]}  ${holidayId5}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s
    ${resp}=   Get Holiday By Id   ${holidayId5}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId5} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime}

    ${resp}=  Get Waitlist By Id  ${cwid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${fday}  waitlistStatus=${wl_status[4]}   paymentStatus=${paymentStatus[3]}
    
    ${resp}=   Delete Holiday  ${holidayId5}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId5}"

    ${resp}=  Get Waitlist By Id  ${cwid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${fday}  waitlistStatus=${wl_status[4]}   paymentStatus=${paymentStatus[3]}

    
JD-TC-ActivateHoliday-4
    [Documentation]  Taking future waitlist from consumer side for a prepayment service ,then creating a holiday and activate status is false then check waitlist status then deleting that holiday


    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid2}=  get_id  ${CUSERNAME5}
    Set Suite Variable   ${cid2}

    ${fday}=  db.add_timezone_date  ${tz}  2       
    ${msg}=  FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${fday}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid1}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}  2
    ${balamount1}=  Evaluate  ${totalamt}-${min_pre}
    ${balamount}=  Convert To Number  ${balamount1}  2

    ${resp}=  Get consumer Waitlist By Id  ${cwid1}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${cwid1}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${min_pre}  ${bool[1]}  ${cwid1}  ${pid}  ${purpose[0]}  ${cid2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME158}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${cwid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid1}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid1}  netTotal=${Tot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre}  amountDue=${balamount}    totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid1}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}   waitlistStatus=${wl_status[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME158}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${desc}=    FakerLibrary.name
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${Last_Day}  ${EMPTY}  ${sTime}  ${eTime}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId5}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   1

    ${resp}=  Get Waitlist By Id  ${cwid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${fday}  waitlistStatus=${wl_status[0]} 
   
    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId5}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s
    ${resp}=   Get Holiday By Id   ${holidayId5}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId5} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime}

    ${resp}=  Get Waitlist By Id  ${cwid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${fday}  waitlistStatus=${wl_status[0]} 
    
    ${resp}=   Delete Holiday  ${holidayId5}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId5}"

    ${resp}=  Get Waitlist By Id  ${cwid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${fday}  waitlistStatus=${wl_status[0]}   paymentStatus=${paymentStatus[1]}

JD-TC-ActivateHoliday-UH1      
    [Documentation]  Activate  holiday by login as consumer

    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Activate Holiday  ${boolean[1]}    ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-ActivateHoliday-UH2
    [Documentation]  Activate holiday without login

    ${resp}=   Activate Holiday  ${boolean[1]}    ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
     
     
JD-TC-ActivateHoliday-UH3
    [Documentation]  Activate holiday details of another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME181}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Activate Holiday  ${boolean[1]}  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  422
   Should Be Equal As Strings  "${resp.json()}"    "${HOLIDAY_NOT_FOUND}"
JD-TC-ActivateHoliday-UH4
    [Documentation]  Activate an invalid holiday details

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Activate Holiday    ${boolean[1]}  0
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${HOLIDAY_NOT_FOUND}"
     
JD-TC-ActivateHoliday-UH5
    [Documentation]   Take waitlist and then create a  holiday for the 3 days and try to take a waitlist

    clear_service    ${PUSERNAME31}
    clear_location   ${PUSERNAME31}
    clear_queue      ${PUSERNAME31}
    clear_customer   ${PUSERNAME31}

    ${resp}=  Encrypted Provider Login     ${PUSERNAME31}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME31}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      

    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${strt_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holi}    ${resp.json()['holidayId']}
    # Should Be Equal As Strings   ${resp.json()['waitlistCount']}   2

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${HOLIDAY_NON_WORKING_DAY}"
     

#waitlig time token

JD-TC-ActivateHoliday-5
    [Documentation]   Take waitlists and then create a  holiday for the 3 days here activate holiday status is true check waitliststatus and waiting time (coventional mode)

    clear_service    ${PUSERNAME35}
    clear_location   ${PUSERNAME35}
    clear_queue      ${PUSERNAME35}
    clear_customer   ${PUSERNAME35}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME35}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME35}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name}=    FakerLibrary.name
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}
    ${ser_name2}=    FakerLibrary.name   
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid3}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid3[0]}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   3

    ${wait_time}=  Evaluate  ((${duration}+${duration})/2)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  appxWaitingTime=0

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=${wait_time} 

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  appxWaitingTime=${wait_time1} 

    ${resp}=   Activate Holiday  ${boolean[1]}  ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}

    
JD-TC-ActivateHoliday-6
    [Documentation]   Take waitlist and then create a  holiday for 3 days here activate holiday status is false and check waitliststatus (coventional)

    clear_service    ${PUSERNAME35}
    clear_location   ${PUSERNAME35}
    clear_queue      ${PUSERNAME35}
    clear_customer   ${PUSERNAME35}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME35}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME35}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name}=    FakerLibrary.name
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}
    ${ser_name2}=    FakerLibrary.name   
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid3}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid3[0]}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=    add_timezone_time  ${tz}  2  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   3

    ${wait_time}=  Evaluate  ((${duration}+${duration})/2)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}

    ${serviceTime1}=   add_two   ${end_time1}       ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}    ${wait_time}
   
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=0

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=${wait_time} 

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=${wait_time1} 

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=0   serviceTime=${end_time1} 

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=${wait_time}   serviceTime=${serviceTime1} 

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}   appxWaitingTime=${wait_time1}   serviceTime=${serviceTime2} 

    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

    
JD-TC-ActivateHoliday-7
    [Documentation]   Take waitlist and then create a full time holiday here activate holiday status is false and try to check waitliststatus (coventional)

    clear_service    ${PUSERNAME35}
    clear_location   ${PUSERNAME35}
    clear_queue      ${PUSERNAME35}
    clear_customer   ${PUSERNAME35}

    ${resp}=  Encrypted Provider Login     ${PUSERNAME35}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME35}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name}=    FakerLibrary.name
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}
    ${ser_name2}=    FakerLibrary.name   
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid3}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid3[0]}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   3

    ${wait_time}=  Evaluate  ((${duration}+${duration})/2)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1} 
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1} 
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}

    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}

    
JD-TC-ActivateHoliday-8
    [Documentation]   Take waitlist and then create a  holiday for the 3 days here activate holiday status is false and check waitliststatus (ML)

    clear_service    ${PUSERNAME35}
    clear_location   ${PUSERNAME35}
    clear_queue      ${PUSERNAME35}
    clear_customer   ${PUSERNAME35}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME35}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME35}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name}=    FakerLibrary.name
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}
    ${ser_name2}=    FakerLibrary.name   
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid3}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid3[0]}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=    add_timezone_time  ${tz}  2  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   3

    ${wait_time}=  Evaluate  ((${duration}+${duration})/2)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1} 
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s

    ${serviceTime1}=   add_two   ${end_time1}      ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}
   
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
   

    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}

JD-TC-ActivateHoliday-9
    [Documentation]   Take waitlist and then create a  holiday for the 3 days here activate holiday status is false and check waitliststatus (fixed mode)

    clear_service    ${PUSERNAME35}
    clear_location   ${PUSERNAME35}
    clear_queue      ${PUSERNAME35}
    clear_customer   ${PUSERNAME35}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME35}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME35}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name}=    FakerLibrary.name
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}
    ${ser_name2}=    FakerLibrary.name   
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid3}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid3[0]}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=    add_timezone_time  ${tz}  2  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   3

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}


    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    sleep   04s
    
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${end_time1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${end_time1}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
   
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}


JD-TC-ActivateHoliday-10
    [Documentation]   Take waitlist and then create a  holiday for the 3 days here activate holiday status is false and check waitliststatus (token)

    clear_service    ${PUSERNAME35}
    clear_location   ${PUSERNAME35}
    clear_queue      ${PUSERNAME35}
    clear_customer   ${PUSERNAME35}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME35}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME35}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name}=    FakerLibrary.name
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}
    ${ser_name2}=    FakerLibrary.name   
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid3}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid3[0]}
      
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=    add_timezone_time  ${tz}  2  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   3

    ${wait_time}=  Evaluate  ((${duration}+${duration})/2)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s
    ${serviceTime1}=   add_two   ${end_time1}      ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time}
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
   
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time1}


JD-TC-ActivateHoliday-UH6
    [Documentation]   create 2 holiday (diffrent 2 future date) then create another holiday between this day

    clear_service    ${PUSERNAME35}
    clear_location   ${PUSERNAME35}
    clear_queue      ${PUSERNAME35}
    clear_customer   ${PUSERNAME35}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME35}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME35}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name}=    FakerLibrary.name
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}
    ${ser_name2}=    FakerLibrary.name   
    ${resp}=  Create Sample Service   ${ser_name2}
    Set Test Variable    ${ser_id2}   ${resp}  
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}     
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      
    
    ${Last_Day}=  db.add_timezone_date  ${tz}  1
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=    add_timezone_time  ${tz}  2  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${Last_Day}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0


    ${Last_Day1}=  db.add_timezone_date  ${tz}   2
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=    add_timezone_time  ${tz}  2  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${Last_Day1}  ${Last_Day1}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0

    ${Last_Day2}=  db.add_timezone_date  ${tz}   3
    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${end_time1}=    add_timezone_time  ${tz}  2  00   
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day2}  ${EMPTY}  ${cur_time}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_ALREADY_NON_WORKING_DAY}"

   




   



























***comment***
   JD-TC-ActivateHoliday-11
    [Documentation]   Take waitlist and then create a  holiday for the 3 days and try to check waitliststatus

    clear_service    ${PUSERNAME186}
    clear_location   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}


    ${resp}=  Encrypted Provider Login     ${PUSERNAME186}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ACC_ID30}=  get_acc_id    ${PUSERNAME186}
    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}
    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name}=    FakerLibrary.name
    Set Test Variable     ${ser_name}
    ${resp}=  Create Sample Service   ${ser_name}
    Set Test Variable    ${ser_id}   ${resp}   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}


    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Last_Day}=  db.add_timezone_date  ${tz}   3

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${endday}=   db.add_timezone_date  ${tz}  15  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${endday}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
      

    # ${cur_time}=  db.get_time_by_timezone   ${tz}  
    ${cur_time}=  db.get_time_by_timezone  ${tz}    
    ${desc}=    FakerLibrary.name
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${cur_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId1}    ${resp.json()['holidayId']}
    # Should Be Equal As Strings   ${resp.json()['waitlistCount']}   2

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
      

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]} 

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]} 

   
    # ${resp}=  Get Waitlist By Id  ${wid1} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # # Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    # ${resp}=  Get Waitlist By Id  ${wid2} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # # Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    ${holi_time}=  add_timezone_time  ${tz}  0  30  
    ${desc}=    FakerLibrary.name
    ${resp}=  Update Holiday   ${holidayId1}  ${desc}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${holi_time}  ${end_time}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Activate Holiday  ${boolean[0]}  ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 

    sleep   04s

    ${resp}=   Get Holiday By Id   ${holidayId1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    # Verify Response    ${resp}  description=${desc}  id=${holidayId1} 
    # Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    # Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    # Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    # Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    # Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${cur_time}  
    # Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
