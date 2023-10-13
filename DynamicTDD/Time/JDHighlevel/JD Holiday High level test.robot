*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
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
${SERVICE1}    Cutting11101
${SERVICE2}    Cutting11
 
*** Test Cases ***

JD-TC-HolidayHighlevel-1
      [Documentation]  create a  holiday for the current day, Then update queue and checking waitlist operations[Fixed calculation mode]
      ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_service   ${PUSERNAME10} 
      ${description}=  FakerLibrary.sentence
      ${ser_dutratn}=   Random Int   min=8   max=8
      ${total_amount1}=  Random Int   min=100  max=500
      ${min_prepayment}=   Random Int   min=10  max=50
      ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${sId_1}  ${resp.json()}
      ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${sId_2}  ${resp.json()}
      clear_location  ${PUSERNAME10}
      # ${city}=   get_place
      # Set Suite Variable  ${city}
      # ${latti}=  get_latitude
      # Set Suite Variable  ${latti}
      # ${longi}=  get_longitude
      # Set Suite Variable  ${longi}
      # ${postcode}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode}
      # ${address}=  get_address
      # Set Suite Variable  ${address}
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      Set Suite Variable  ${tz}
      Set Suite Variable  ${city}
      Set Suite Variable  ${latti}
      Set Suite Variable  ${longi}
      Set Suite Variable  ${postcode}
      Set Suite Variable  ${address}
      ${parking}    Random Element   ${parkingType}
      Set Suite Variable  ${parking}
      ${24hours}    Random Element    ${bool}
      Set Suite Variable  ${24hours}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY}
      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}
      # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
      Set Suite Variable   ${sTime}
      ${eTime}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}
      Sleep  2s
      # ${resp}=  Get Queues
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Suite Variable  ${qid}  ${resp.json()[0]['id']}

      ${DAY2}=  db.add_timezone_date  ${tz}  10  
      ${queue_name}=  FakerLibrary.bs
      ${parallel}=   Random Int  min=1   max=1
      ${capacity}=  Random Int   min=10   max=20
      ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
      ${eTime1}=  add_timezone_time  ${tz}  3  30  
      Set Test Variable  ${qTime}   ${sTime1}-${eTime1}
      ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${sId_1}  ${sId_2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid}  ${resp.json()}

      ${trnTime}=   Random Int   min=10   max=20
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${description}=  FakerLibrary.word
      # ${resp}=  Create Holiday  ${DAY}  ${description}  ${stime}  ${etime}
      ${list}=  Create List   1  2  3  4  5  6  7
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY}  ${EMPTY}  ${stime}  ${etime}  ${description}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${hId}    ${resp.json()['holidayId']}

      ${resp}=   Get Holiday By Id  ${hId}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${acid}=  get_acc_id  ${PUSERNAME10}
      Verify Response   ${resp}  startDay=${DAY}  description=${description}
      Should Be Equal As Strings  ${resp.json()['nonWorkingHours']['sTime']}  ${stime}
      Should Be Equal As Strings  ${resp.json()['nonWorkingHours']['eTime']}  ${etime}
      ${resp}=  Get Queue By Location and service By Date  ${lid}  ${sId_1}  ${DAY}  ${acid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Should Not Contain  ${resp.json()}  id=${qid}
      ${hTime}=  add_timezone_time  ${tz}  0  ${trnTime}  
      ${queue1}=  FakerLibrary.word
      ${resp}=  Update Queue  ${qid}  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${hTime}  1  3  ${lid}  ${sId_1}  ${sId_2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Sleep  2s
      ${resp}=  Get Queue By Location and service By Date  ${lid}  ${sId_1}  ${DAY}  ${acid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['sTime']}  ${etime}
      Should Be Equal As Strings  ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['eTime']}  ${hTime}

      ${cid}=  get_id  ${CUSERNAME1}
      ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  appxWaitingTime=${trnTime}

      ${cid}=  get_id  ${CUSERNAME2}
      ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WATLIST_MAX_LIMIT_REACHED}"

      ${resp}=  Waitlist Action Cancel  ${wid}  ${waitlist_cancl_reasn[4]}  ${description}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-HolidayHighlevel-2
      [Documentation]  update queue again and checking waitlist operations[Fixed calculation mode]
      ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${lTime}=  add_timezone_time  ${tz}  0  20  
      ${queue1}=  FakerLibrary.word
      ${resp}=  Update Queue  ${qid}  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${lTime}  1  1  ${lid}  ${sId_1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Sleep   04s
      ${acid}=  get_acc_id  ${PUSERNAME10}
      ${resp}=  Get Queue By Location and service By Date  ${lid}  ${sId_1}  ${DAY}  ${acid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Not Contain  ${resp.json()}  id=${qid}

      ${cid}=  get_id  ${CUSERNAME1}
      ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}"

JD-TC-HolidayHighlevel-3
      [Documentation]  create a  holiday in between the husiness schedule, Then checking waitlist operations[Fixed calculation mode]
      ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_service   ${PUSERNAME20} 
      ${description}=  FakerLibrary.sentence
      ${ser_dutratn}=   Random Int   min=8   max=8
      ${total_amount1}=  Random Int   min=100  max=500
      ${min_prepayment}=   Random Int   min=10  max=50
      ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${sId_1}  ${resp.json()}
      ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${sId_2}  ${resp.json()}
      clear_location  ${PUSERNAME20}
      # ${city}=   get_place
      # Set Suite Variable  ${city}
      # ${latti}=  get_latitude
      # Set Suite Variable  ${latti}
      # ${longi}=  get_longitude
      # Set Suite Variable  ${longi}
      # ${postcode}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode}
      # ${address}=  get_address
      # Set Suite Variable  ${address}
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      Set Suite Variable  ${tz}
      Set Suite Variable  ${city}
      Set Suite Variable  ${latti}
      Set Suite Variable  ${longi}
      Set Suite Variable  ${postcode}
      Set Suite Variable  ${address}
      ${parking}    Random Element   ${parkingType}
      Set Suite Variable  ${parking}
      ${24hours}    Random Element    ${bool}
      Set Suite Variable  ${24hours}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY}
      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}
      ${sTime}=  add_timezone_time  ${tz}  0  1
      Set Suite Variable   ${sTime}
      ${eTime}=  add_timezone_time  ${tz}  4  0  
      Set Suite Variable   ${eTime}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid}  ${resp.json()}
      Sleep  2s
      ${resp}=  Get Queues
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid}  ${resp.json()[0]['id']}
      ${trnTime}=   Random Int   min=60   max=60
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${description}=  FakerLibrary.word
      ${h1}=  add_timezone_time  ${tz}  2  0    
      ${h2}=  add_timezone_time  ${tz}  3  0  
      # ${resp}=  Create Holiday  ${DAY}  ${description}  ${h1}  ${h2}
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      ${list}=  Create List   1  2  3  4  5  6  7
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY}  ${EMPTY}  ${h1}  ${h2}  ${description}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${hId}    ${resp.json()['holidayId']}

      ${resp}=   Get Holiday By Id  ${hId}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response   ${resp}  startDay=${DAY}  description=${description}
      Should Be Equal As Strings  ${resp.json()['nonWorkingHours']['sTime']}  ${h1}
      Should Be Equal As Strings  ${resp.json()['nonWorkingHours']['eTime']}  ${h2}
      sleep  03s
      ${acid}=  get_acc_id  ${PUSERNAME20}
      ${resp}=  Get Queue By Location and service By Date  ${lid}  ${sId_1}  ${DAY}  ${acid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['sTime']}  ${sTime}
      Should Be Equal As Strings  ${resp.json()[0]['effectiveSchedule']['timeSlots'][0]['eTime']}  ${h1}
      Should Be Equal As Strings  ${resp.json()[0]['effectiveSchedule']['timeSlots'][1]['sTime']}  ${h2}
      Should Be Equal As Strings  ${resp.json()[0]['effectiveSchedule']['timeSlots'][1]['eTime']}  ${eTime}
      clear_Consumermsg  ${CUSERNAME1}
      clear_Consumermsg  ${CUSERNAME2}
      clear_Consumermsg  ${CUSERNAME3}
      ${cid}=  get_id  ${CUSERNAME1}
      ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  appxWaitingTime=${trnTime}
      ${cid1}=  get_id  ${CUSERNAME2}
      ${resp}=  Add To Waitlist  ${cid1}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid2}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid2}  ${wid2[0]}
      ${resp}=  Get Waitlist By Id  ${wid2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  appxWaitingTime=${trnTime}
      sleep  03s
      change_system_time  2  10
      ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${cid2}=  get_id  ${CUSERNAME3}
      ${resp}=  Add To Waitlist  ${cid2}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid3}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid3}  ${wid3[0]}
      ${resp}=  Get Waitlist By Id  ${wid3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  appxWaitingTime=${trnTime}
      ${cid3}=  get_id  ${CUSERNAME4}
      ${resp}=  Add To Waitlist  ${cid3}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WATLIST_MAX_LIMIT_REACHED}"


JD-TC-HolidayHighlevel-4
      [Documentation]   Add a consumer to the waitlist for the current day
      ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_service   ${PUSERNAME30} 
      ${description}=  FakerLibrary.sentence
      ${ser_dutratn}=   Random Int   min=8   max=20
      ${total_amount1}=  Random Int   min=100  max=500
      ${min_prepayment}=   Random Int   min=10  max=50
      ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${sId_1}  ${resp.json()}
      ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${sId_2}  ${resp.json()}
      clear_location  ${PUSERNAME30}
      # ${city}=   get_place
      # Set Suite Variable  ${city}
      # ${latti}=  get_latitude
      # Set Suite Variable  ${latti}
      # ${longi}=  get_longitude
      # Set Suite Variable  ${longi}
      # ${postcode}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode}
      # ${address}=  get_address
      # Set Suite Variable  ${address}
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      Set Suite Variable  ${tz}
      Set Suite Variable  ${city}
      Set Suite Variable  ${latti}
      Set Suite Variable  ${longi}
      Set Suite Variable  ${postcode}
      Set Suite Variable  ${address}
      ${parking}    Random Element   ${parkingType}
      Set Suite Variable  ${parking}
      ${24hours}    Random Element    ${bool}
      Set Suite Variable  ${24hours}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY}
      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}
      # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
      Set Suite Variable   ${sTime}
      ${eTime}=  add_timezone_time  ${tz}   0  120
      Set Suite Variable   ${eTime}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid}  ${resp.json()}
      Sleep  2s
      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid}  ${resp.json()[0]['id']}
      ${trnTime}=   Random Int   min=10   max=20
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${DAY2}=  db.add_timezone_date  ${tz}  2  
      ${cid}=  get_id  ${CUSERNAME1}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY2}  hi  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid2}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY2}  waitlistStatus=${wl_status[0]}

      ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid}  ${DAY2}  hi  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid3}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY2}  waitlistStatus=${wl_status[0]}

      ${cid}=  get_id  ${CUSERNAME2}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY2}  hi  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid4}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid4} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY2}  waitlistStatus=${wl_status[0]}

      # ${resp}=  Create Holiday  ${DAY2}  ${description}  ${sTime}  ${eTime}
      # Should Be Equal As Strings  ${resp.status_code}  200
      ${list}=  Create List   1  2  3  4  5  6  7
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${sTime}  ${eTime}  ${description}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${hId}    ${resp.json()['holidayId']}

      ${resp}=   Get Holiday By Id  ${hId}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response   ${resp}  startDay=${DAY2}  description=${description}
      Should Be Equal As Strings  ${resp.json()['nonWorkingHours']['sTime']}  ${sTime}
      Should Be Equal As Strings  ${resp.json()['nonWorkingHours']['eTime']}  ${eTime}

      sleep  03s
      ${resp}=  Get Waitlist By Id  ${wid2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY2}  waitlistStatus=${wl_status[4]}
      ${resp}=  Get Waitlist By Id  ${wid3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY2}  waitlistStatus=${wl_status[4]}
      ${resp}=  Get Waitlist By Id  ${wid4} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY2}  waitlistStatus=${wl_status[4]}




      