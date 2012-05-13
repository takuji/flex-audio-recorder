package jp.psyark.net {
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.utils.ByteArray;
    /**
     * multipart/form-dataのリクエストを作成するための簡単なクラスです。
     */
    public class MultipartFormDataBuilder {
        protected var _boundary:String;
        protected var byteArray:ByteArray;
 
        /**
         * コンストラクタです。
         *
         * @param boundary バウンダリ（境界線）文字列です。送信する他のデータ中に出現しない文字列である必要があります。
         */
        public function MultipartFormDataBuilder(boundary:String) {
            _boundary = boundary;
            byteArray = new ByteArray();
            addBoundary(false);
        }
 
        /**
         * パート（部分）を追加します。
         *
         * @param name このパートの名前です。content-dispositionヘッダのname属性に使われます。
         * @param data このパートのデータです。ByteArray以外の値は文字列として評価されます。
         * @param filename このパートのファイル名です。null以外の値を渡した場合、content-dispositionヘッダのfilename属性に使われます。
         */
        public function addPart(name:String, data:*, contentType:String=null, filename:String=null, isLast:Boolean=false):void {
            byteArray.writeUTFBytes('Content-Disposition: form-data; name="' + name + '"');
            if (filename != null) {
                byteArray.writeUTFBytes('; filename="' + filename + '"');
                byteArray.writeUTFBytes("\r\n");
                byteArray.writeUTFBytes("Content-Type: " + contentType);
            }
 
            byteArray.writeUTFBytes("\r\n\r\n");
            if (data is ByteArray) {
                byteArray.writeBytes(data);
            } else {
                byteArray.writeUTFBytes(data);
            }
            byteArray.writeUTFBytes("\r\n");
            addBoundary(isLast);
        }
 
        /**
         * multipart/form-dataのリクエストとして使えるように、URLRequestを設定します。
         */
        public function configure(request:URLRequest):void {
            request.method = URLRequestMethod.POST;
            request.data = byteArray;
            request.contentType = "multipart/form-data, boundary=" + _boundary;
        }
        
        private function addBoundary(isLast:Boolean):void {
          if (isLast) {
            byteArray.writeUTFBytes("--" + _boundary + "--\r\n");
          } else {
            byteArray.writeUTFBytes("--" + _boundary + "\r\n");
          }
        }
    }
}
