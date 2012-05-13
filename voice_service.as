import flash.media.Microphone;
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.net.FileReference;
import ghostcat.fileformat.wav.WAVWriter;
import mx.controls.Alert;
import jp.psyark.net.MultipartFormDataBuilder;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

private function uploadWavFile(url:String, wav:ByteArray, filename:String):void {
  var request:URLRequest = new URLRequest();
  var loader:URLLoader = new URLLoader();
  var builder:MultipartFormDataBuilder = new MultipartFormDataBuilder("247672365515574");
  loader.addEventListener(Event.COMPLETE, uploadSucceeded);
  loader.addEventListener(IOErrorEvent.IO_ERROR, uploadFailed);
  loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, uploadHttpStatusHandler);
  request.url = "http://localhost:3000/appeals";
  builder.addPart("user_id", "1");
  builder.addPart("audio_message", wav, "audio/wav", filename, true);
  builder.configure(request);
  loader.load(request);
}

private function uploadSucceeded(event:Event):void {
  
}

private function uploadHttpStatusHandler(event:Event):void {
  
}

private function uploadFailed(event:Event):void {
  
}

protected var audioData:ByteArray;
protected var microphone:Microphone;
protected var channel:SoundChannel;
private var startTime:Date;
private var timer:Timer;
private var wavData:ByteArray;
private var samplingRateFactor:int = 2;
/*
private function init():void {
  if (Microphone.isSupported) {

  }
}
*/
private function startRecording():void {
  trace("Start recording");
  microphone = Microphone.getMicrophone(0);
  microphone.rate = 44 / samplingRateFactor;
  microphone.gain = 100;
  audioData = new ByteArray();
  startTime = new Date();
  timer = new Timer(1000);
  resetTimeDisplay();
  timer.addEventListener("timer", updateTimeDisplay);
  timer.start();
  microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleDataReceived);

  stopStatePanel.visible = false;
  recordingStatePanel.visible = true;
}
private function stopRecording():void {
  trace("Stopped recording");
  microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleDataReceived);
  timer.removeEventListener("timer", updateTimeDisplay);
  timer.stop();

  showPanel(hasDataStatePanel);
}
private function startPlaying():void {
  audioData.position = 0;
  var audio:Sound = new Sound();
  startTime = new Date();
  timer = new Timer(1000);
  resetTimeDisplay();
  timer.addEventListener("timer", updateTimeDisplay)
  timer.start();
  audio.addEventListener(SampleDataEvent.SAMPLE_DATA, audioSampleHandler);
  channel = audio.play();
  channel.addEventListener(Event.SOUND_COMPLETE, audioCompleteHandler);

  showPanel(playingStatePanel);
}
private function stopPlaying():void {
  timer.removeEventListener("timer", updateTimeDisplay);
  timer.stop();

  showPanel(hasDataStatePanel);
}
private function reset():void {
  showPanel(stopStatePanel);
}
private function upload():void {
  wavData = makeWavFile(audioData);
  var f:FileReference = new FileReference();
  uploadWavFile("http://localhost:3000/appeals", wavData, "appeal.wav");
  //f.save(wavData, "appeal.wav");
  showPanel(stopStatePanel);
}

private function showPanel(panel:Group):void {
  stopStatePanel.visible = false;
  recordingStatePanel.visible = false;
  hasDataStatePanel.visible = false;
  playingStatePanel.visible = false;

  panel.visible = true;
}

private function onSampleDataReceived(event:SampleDataEvent):void {
  while (event.data.bytesAvailable) {
    var sample:Number = event.data.readFloat();
    audioData.writeFloat(sample);
  }
}
private function audioSampleHandler(event:SampleDataEvent):void {
  if (!audioData.bytesAvailable > 0) {
    return;
  }
  var n:int = 8192 / samplingRateFactor;
  for (var i:int = 0; i < n; i++) {
    var sample:Number = 0;
    if (audioData.bytesAvailable > 0) {
      sample = audioData.readFloat();
    }
    for (var j:int = 0; j < samplingRateFactor; j++) {
      event.data.writeFloat(sample);
      event.data.writeFloat(sample);
    }
  }
}
private function audioCompleteHandler(event:Event):void {
  timer.removeEventListener("timer", updateTimeDisplay);
  timer.stop();
  showPanel(hasDataStatePanel);
}
private function updateTimeDisplay(event:TimerEvent):void {
  var currentTime:Date = new Date();
  var sec:int = int((currentTime.time - startTime.time) / 1000);
  timeDisplay.text = zeroPad(sec.toString(), 2);
}
private function resetTimeDisplay():void {
  timeDisplay.text = zeroPad(Number(0).toString(), 2);
}
private function zeroPad (number:String, width:int):String {
  if (number.length < width) {
    return "0" + zeroPad(number, width-1);
  }
  return number;
}

private function makeWavFile(rawData:ByteArray): ByteArray {
  try {
    var buf:ByteArray = new ByteArray();
    var wavWriter:WAVWriter = new WAVWriter();
    var samplingRate:int = 44000 / samplingRateFactor;
    wavWriter.numOfChannels = 1;
    wavWriter.samplingRate = samplingRate;
    rawData.position = 0;
    wavWriter.processSamples(buf, rawData, samplingRate, 1);
    return buf;
  } catch (e:Error) {
    trace(e);
    Alert.show(e.message, "Alert Window Title", Alert.OK);
    return null;
  }
  return null;
}
