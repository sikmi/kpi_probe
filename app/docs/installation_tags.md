# Matomoタグの設置
本項ではRailsを使用した場合を一例として説明しています。
他のフレームワークで使用する際は適宜変更してください。

## トラッキングタグの設置(ユーザーIDの紐付け)
基本的なMatomoのに**ユーザーIDの紐付け**を追加してください。
```javascript
var _paq = window._paq = window._paq || [];
/* tracker methods like "setCustomDimension" should be called before "trackPageView" */
_paq.push(['setUserId', #{current_user&.id}]);  /* ←ここを追加 */
_paq.push(['trackPageView']);
_paq.push(['enableLinkTracking']);
(function() {
  var u="//localhost/";
  _paq.push(['setTrackerUrl', u+'matomo.php']);
  _paq.push(['setSiteId', '1']);
  var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
  g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
})();
```

## カスタムイベントタグの設置
以下のような形式でjavscriptのタグを任意で設置します
```javascript
_paq.push(['trackEvent', 'プロセス名', '計測の開始or終了', 'URL::hash'])
```
  ### タグの詳細
  - **プロセス名**: 
    計測する対象のイベントに名前をつけることができます。
    一覧表示時に「プロセス名」の欄に表示される名前です。
    日本語・英数字使用可能。記号は`_`のみ使用可能です。

  - **計測の開始or終了**: 
  必ず`Start`または`Finish`のどちらかを入れてください。
  `Start`タグが実行されてから`Finish`タグが実行されるまでの時間が
  一覧の「計測時間」欄に表示されます。

  - **URL::hash**
    URLには現在地のURLを入れることを想定しています。
    hashには`Start`と`Finish`の同一性を担保するためにランダムな一意の値を入れます。
    この2つを`::`で繋いで入れてください。

  ### 例
  ページを読み込んだ時からsubmitボタンで確定した時までの時間を「EditPost」というプロセス名で計測したい場合の一例です。
  - `Start`タグ
    `window.onload`で読み込み時にタグを作成させます。
    ```javascript
    var trackingId = Math.random().toString(32).substring(2)  // 開始と完了の同一性を判断する値を作っておく（被らない値であればよい）
    window.onload = function() {
      _paq.push(['trackEvent', 'EditPost', 'Start', '#{request.fullpath}' + '::' + trackingId])
    }
    ```

  - `Finish`タグ
    submitボタン`onclick`でタグを作成させます。
    ```ruby
    f.submit ..., onclick: "_paq.push(['trackEvent', 'EditPost', 'Finish', '#{request.fullpath}' + '::' + trackingId])"
    # trackingIdはStartの時と同じものを設定してください
    ```
