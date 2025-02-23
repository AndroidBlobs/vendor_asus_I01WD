#!/system/bin/sh

check_audio_calibration=`getprop audio.calibration.spk`

echo "[ASUS][SpeakerCalibration] Begin Check Speaker calibration status" > /dev/kmsg
log -p d -t [ASUS][SpeakerCalibration] Begin Check Speaker calibration status
echo "[ASUS][SpeakerCalibration] Check Speaker calibration status audio.calibration.spk = $check_audio_calibration" > /dev/kmsg
log -p d -t [ASUS][SpeakerCalibration] Check Speaker calibration status audio.calibration.spk = $check_audio_calibration

if [ "${check_audio_calibration}" != "pass" ];
	then
	echo "[ASUS][SpeakerCalibration] Without Speaker calibration property" > /dev/kmsg
	log -p d -t [ASUS][SpeakerCalibration] Without Speaker calibration property

	if [ ! -f "/vendor/factory/cal_s_speaker0_log.txt" ];then
		echo "[ASUS][SpeakerCalibration] Original /vendor/factory/cal_s_speaker0_log.txt does not exist" > /dev/kmsg
		log -p d -t [ASUS][SpeakerCalibration] Original /vendor/factory/cal_s_speaker0_log.txt does not exist
	else
		check_audio_calibration_data=$(cat /vendor/factory/cal_s_speaker0_log.txt)
		echo "[ASUS][SpeakerCalibration] Original /vendor/factory/cal_s_speaker0_log.txt = $check_audio_calibration_data" > /dev/kmsg
		log -p d -t [ASUS][SpeakerCalibration] Original /vendor/factory/cal_s_speaker0_log.txt = $check_audio_calibration_data
	fi

	if [ ! -f "/mnt/vendor/asusfw/audio/cal_self_speaker0_log.txt" ];then
		echo "[ASUS][SpeakerCalibration] Without /mnt/vendor/asusfw Speaker calibration data, begin calibration again" > /dev/kmsg
		log -p d -t [ASUS][SpeakerCalibration] Without Speaker calibration data, begin calibration again

		sleep 1

		Temp_data=`climax -dsysfs -l /vendor/firmware/stereo.cnt --resetmtpex`

		Temp_data=`climax -dsysfs -l /vendor/firmware/stereo.cnt --calshow`
		echo $Temp_data > /mnt/vendor/asusfw/audio/cal_self_recal_speaker0_log_tmp.txt

		Temp_data=`climax -dsysfs -l /vendor/firmware/stereo.cnt --calibrate=once`
		echo $Temp_data > /mnt/vendor/asusfw/audio/cal_self_speaker0_log_tmp.txt

		Temp_data=`climax -d /dev/i2c-1 --slave=0x35 -r 0xf5`
		echo $Temp_data > /mnt/vendor/asusfw/audio/cal_self_receiver0_data_tmp.txt
		/vendor/bin/SpeakerCalibrationTest 5 > /dev/null
	else
		check_audio_calibration_data=$(cat /mnt/vendor/asusfw/audio/cal_self_speaker0_log.txt)

		echo "[ASUS][SpeakerCalibration] Self calibration begin" > /proc/asusevtlog

		echo "[ASUS][SpeakerCalibration] /mnt/vendor/asusfw/audio/cal_self_speaker0_log.txt = $check_audio_calibration_data still need calibration" > /dev/kmsg
		log -p d -t [ASUS][SpeakerCalibration] /mnt/vendor/asusfw/audio/cal_self_speaker0_log.txt = $check_audio_calibration_data  still need calibration


		echo 0 > /mnt/vendor/asusfw/audio/0x34_aftercalmtp.txt
		echo 0 > /mnt/vendor/asusfw/audio/0x34_origmtp.txt
		echo 0 > /mnt/vendor/asusfw/audio/0x35_aftercalmtp.txt
		echo 0 > /mnt/vendor/asusfw/audio/0x35_origmtp.txt
		echo 0 > /mnt/vendor/asusfw/audio/spkcal_save_0x34_aftercalmtp.txt
		echo 0 > /mnt/vendor/asusfw/audio/spkcal_save_0x34_origmtp.txt
		echo 0 > /mnt/vendor/asusfw/audio/spkcal_save_0x35_aftercalmtp.txt
		echo 0 > /mnt/vendor/asusfw/audio/spkcal_save_0x35_origmtp.txt


		echo "[ASUS][SpeakerCalibration] Speaker Begin calibrated step" > /dev/kmsg
		log -p d -t [ASUS][SpeakerCalibration] Speaker Begin calibrated step

		Temp_data=`climax -dsysfs -l /vendor/firmware/stereo.cnt --resetmtpex -b`
		echo "$Temp_data" > /mnt/vendor/asusfw/audio/cal_self_recal_speaker0_log_tmp.txt

		echo "[ASUS][SpeakerCalibration] Speaker Begin resetmtpex = $Temp_data" > /dev/kmsg
		log -p d -t [ASUS][SpeakerCalibration] Speaker Begin resetmtpex = "$Temp_data"

		sleep 1

		Temp_data=`climax -dsysfs -l /vendor/firmware/stereo.cnt --calibrate=once -b`
		echo "$Temp_data" > /mnt/vendor/asusfw/audio/cal_self_speaker0_log_tmp.txt

		echo "[ASUS][SpeakerCalibration] Speaker Begin calibrated = $Temp_data" > /dev/kmsg
		log -p d -t [ASUS][SpeakerCalibration] Speaker Begin calibrated = "$Temp_data"

		sleep 1

		Temp_data=`climax -d /dev/i2c-1 --slave=0x35 -r 0xf5`
		echo $Temp_data > /mnt/vendor/asusfw/audio/cal_self_speaker0_data_tmp.txt

		echo "[ASUS][SpeakerCalibration] Speaker calibrated result = $Temp_data" > /dev/kmsg
		log -p d -t [ASUS][SpeakerCalibration] Speaker calibrated result = $Temp_data

		cp /mnt/vendor/asusfw/audio/0x34_aftercalmtp.txt /mnt/vendor/asusfw/audio/spkcal_save_0x34_aftercalmtp.txt
		cp /mnt/vendor/asusfw/audio/0x34_origmtp.txt /mnt/vendor/asusfw/audio/spkcal_save_0x34_origmtp.txt
		cp /mnt/vendor/asusfw/audio/0x35_aftercalmtp.txt /mnt/vendor/asusfw/audio/spkcal_save_0x35_aftercalmtp.txt
		cp /mnt/vendor/asusfw/audio/0x35_origmtp.txt /mnt/vendor/asusfw/audio/spkcal_save_0x35_origmtp.txt

		/vendor/bin/sh /vendor/etc/check_rcvcal.sh
		/vendor/bin/SpeakerCalibrationTest 5 > /dev/null

	fi

else
	echo "[ASUS][SpeakerCalibration] Speaker already calibrated" > /dev/kmsg
	log -p d -t [ASUS][SpeakerCalibration] Speaker already calibrated
fi
