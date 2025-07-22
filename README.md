# drm-native-audio

A Capacitor plugin for playing native audio with DRM implementation.

## Install

```bash
npm install drm-native-audio
npx cap sync
```

## API

<docgen-index>

* [`loadPallyconSound(...)`](#loadpallyconsound)
* [`pauseAudio()`](#pauseaudio)
* [`setAudioPlaybackRate(...)`](#setaudioplaybackrate)
* [`seekToTime(...)`](#seektotime)
* [`stopCurrentAudio()`](#stopcurrentaudio)
* [`addListener('soundEnded', ...)`](#addlistenersoundended-)
* [`addListener('isBuffering', ...)`](#addlistenerisbuffering-)
* [`addListener('audioLoaded', ...)`](#addlisteneraudioloaded-)
* [`addListener('notificationPreviousCalled', ...)`](#addlistenernotificationpreviouscalled-)
* [`addListener('notificationNextCalled', ...)`](#addlistenernotificationnextcalled-)
* [`addListener('playerError', ...)`](#addlistenerplayererror-)
* [`addListener('isAudioPlaying', ...)`](#addlistenerisaudioplaying-)
* [`addListener('isAudioPause', ...)`](#addlistenerisaudiopause-)
* [`playAudio()`](#playaudio)
* [`getPaused()`](#getpaused)
* [`getCurrentTime()`](#getcurrenttime)
* [`removeNotificationAndClearAudio()`](#removenotificationandclearaudio)
* [`loadAudioLecture(...)`](#loadaudiolecture)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### loadPallyconSound(...)

```typescript
loadPallyconSound(options: { audioURL: String; author: String; token: String; notificationThumbnail: String; title: String; seekTime: number; contentId: String; isSampleAudio: Boolean; email: String; }) => Promise<void>
```

| Param         | Type                                                                                                                                                                                                                                                                                                                                                                         |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ audioURL: <a href="#string">String</a>; author: <a href="#string">String</a>; token: <a href="#string">String</a>; notificationThumbnail: <a href="#string">String</a>; title: <a href="#string">String</a>; seekTime: number; contentId: <a href="#string">String</a>; isSampleAudio: <a href="#boolean">Boolean</a>; email: <a href="#string">String</a>; }</code> |

--------------------


### pauseAudio()

```typescript
pauseAudio() => Promise<void>
```

--------------------


### setAudioPlaybackRate(...)

```typescript
setAudioPlaybackRate(options: { speed: number; }) => Promise<void>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ speed: number; }</code> |

--------------------


### seekToTime(...)

```typescript
seekToTime(options: { seekTime: number; }) => Promise<void>
```

| Param         | Type                               |
| ------------- | ---------------------------------- |
| **`options`** | <code>{ seekTime: number; }</code> |

--------------------


### stopCurrentAudio()

```typescript
stopCurrentAudio() => Promise<void>
```

--------------------


### addListener('soundEnded', ...)

```typescript
addListener(eventName: 'soundEnded', listenerFunc: () => void) => Promise<PluginListenerHandle>
```

| Param              | Type                       |
| ------------------ | -------------------------- |
| **`eventName`**    | <code>'soundEnded'</code>  |
| **`listenerFunc`** | <code>() =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('isBuffering', ...)

```typescript
addListener(eventName: 'isBuffering', listenerFunc: () => void) => Promise<PluginListenerHandle>
```

| Param              | Type                       |
| ------------------ | -------------------------- |
| **`eventName`**    | <code>'isBuffering'</code> |
| **`listenerFunc`** | <code>() =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('audioLoaded', ...)

```typescript
addListener(eventName: 'audioLoaded', listenerFunc: (soundDuration: number) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                            |
| ------------------ | ----------------------------------------------- |
| **`eventName`**    | <code>'audioLoaded'</code>                      |
| **`listenerFunc`** | <code>(soundDuration: number) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('notificationPreviousCalled', ...)

```typescript
addListener(eventName: 'notificationPreviousCalled', listenerFunc: () => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                      |
| ------------------ | ----------------------------------------- |
| **`eventName`**    | <code>'notificationPreviousCalled'</code> |
| **`listenerFunc`** | <code>() =&gt; void</code>                |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('notificationNextCalled', ...)

```typescript
addListener(eventName: 'notificationNextCalled', listenerFunc: () => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                  |
| ------------------ | ------------------------------------- |
| **`eventName`**    | <code>'notificationNextCalled'</code> |
| **`listenerFunc`** | <code>() =&gt; void</code>            |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('playerError', ...)

```typescript
addListener(eventName: 'playerError', listenerFunc: (message: any) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                   |
| ------------------ | -------------------------------------- |
| **`eventName`**    | <code>'playerError'</code>             |
| **`listenerFunc`** | <code>(message: any) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('isAudioPlaying', ...)

```typescript
addListener(eventName: 'isAudioPlaying', listenerFunc: (error: any) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                 |
| ------------------ | ------------------------------------ |
| **`eventName`**    | <code>'isAudioPlaying'</code>        |
| **`listenerFunc`** | <code>(error: any) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('isAudioPause', ...)

```typescript
addListener(eventName: 'isAudioPause', listenerFunc: (error: any) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                 |
| ------------------ | ------------------------------------ |
| **`eventName`**    | <code>'isAudioPause'</code>          |
| **`listenerFunc`** | <code>(error: any) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### playAudio()

```typescript
playAudio() => Promise<void>
```

--------------------


### getPaused()

```typescript
getPaused() => Promise<{ paused: boolean; }>
```

**Returns:** <code>Promise&lt;{ paused: boolean; }&gt;</code>

--------------------


### getCurrentTime()

```typescript
getCurrentTime() => Promise<{ time: number; }>
```

**Returns:** <code>Promise&lt;{ time: number; }&gt;</code>

--------------------


### removeNotificationAndClearAudio()

```typescript
removeNotificationAndClearAudio() => Promise<void>
```

--------------------


### loadAudioLecture(...)

```typescript
loadAudioLecture(options: { audioURL: String; author: String; notificationThumbnail: String; title: String; seekTime: number; contentId: String; }) => Promise<void>
```

| Param         | Type                                                                                                                                                                                                                                                |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ audioURL: <a href="#string">String</a>; author: <a href="#string">String</a>; notificationThumbnail: <a href="#string">String</a>; title: <a href="#string">String</a>; seekTime: number; contentId: <a href="#string">String</a>; }</code> |

--------------------


### Interfaces


#### String

Allows manipulation and formatting of text strings and determination and location of substrings within strings.

| Prop         | Type                | Description                                                  |
| ------------ | ------------------- | ------------------------------------------------------------ |
| **`length`** | <code>number</code> | Returns the length of a <a href="#string">String</a> object. |

| Method                | Signature                                                                                                                      | Description                                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **toString**          | () =&gt; string                                                                                                                | Returns a string representation of a string.                                                                                                  |
| **charAt**            | (pos: number) =&gt; string                                                                                                     | Returns the character at the specified index.                                                                                                 |
| **charCodeAt**        | (index: number) =&gt; number                                                                                                   | Returns the Unicode value of the character at the specified location.                                                                         |
| **concat**            | (...strings: string[]) =&gt; string                                                                                            | Returns a string that contains the concatenation of two or more strings.                                                                      |
| **indexOf**           | (searchString: string, position?: number \| undefined) =&gt; number                                                            | Returns the position of the first occurrence of a substring.                                                                                  |
| **lastIndexOf**       | (searchString: string, position?: number \| undefined) =&gt; number                                                            | Returns the last occurrence of a substring in the string.                                                                                     |
| **localeCompare**     | (that: string) =&gt; number                                                                                                    | Determines whether two strings are equivalent in the current locale.                                                                          |
| **match**             | (regexp: string \| <a href="#regexp">RegExp</a>) =&gt; <a href="#regexpmatcharray">RegExpMatchArray</a> \| null                | Matches a string with a regular expression, and returns an array containing the results of that search.                                       |
| **replace**           | (searchValue: string \| <a href="#regexp">RegExp</a>, replaceValue: string) =&gt; string                                       | Replaces text in a string, using a regular expression or search string.                                                                       |
| **replace**           | (searchValue: string \| <a href="#regexp">RegExp</a>, replacer: (substring: string, ...args: any[]) =&gt; string) =&gt; string | Replaces text in a string, using a regular expression or search string.                                                                       |
| **search**            | (regexp: string \| <a href="#regexp">RegExp</a>) =&gt; number                                                                  | Finds the first substring match in a regular expression search.                                                                               |
| **slice**             | (start?: number \| undefined, end?: number \| undefined) =&gt; string                                                          | Returns a section of a string.                                                                                                                |
| **split**             | (separator: string \| <a href="#regexp">RegExp</a>, limit?: number \| undefined) =&gt; string[]                                | Split a string into substrings using the specified separator and return them as an array.                                                     |
| **substring**         | (start: number, end?: number \| undefined) =&gt; string                                                                        | Returns the substring at the specified location within a <a href="#string">String</a> object.                                                 |
| **toLowerCase**       | () =&gt; string                                                                                                                | Converts all the alphabetic characters in a string to lowercase.                                                                              |
| **toLocaleLowerCase** | (locales?: string \| string[] \| undefined) =&gt; string                                                                       | Converts all alphabetic characters to lowercase, taking into account the host environment's current locale.                                   |
| **toUpperCase**       | () =&gt; string                                                                                                                | Converts all the alphabetic characters in a string to uppercase.                                                                              |
| **toLocaleUpperCase** | (locales?: string \| string[] \| undefined) =&gt; string                                                                       | Returns a string where all alphabetic characters have been converted to uppercase, taking into account the host environment's current locale. |
| **trim**              | () =&gt; string                                                                                                                | Removes the leading and trailing white space and line terminator characters from a string.                                                    |
| **substr**            | (from: number, length?: number \| undefined) =&gt; string                                                                      | Gets a substring beginning at the specified location and having the specified length.                                                         |
| **valueOf**           | () =&gt; string                                                                                                                | Returns the primitive value of the specified object.                                                                                          |


#### RegExpMatchArray

| Prop        | Type                |
| ----------- | ------------------- |
| **`index`** | <code>number</code> |
| **`input`** | <code>string</code> |


#### RegExp

| Prop             | Type                 | Description                                                                                                                                                          |
| ---------------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`source`**     | <code>string</code>  | Returns a copy of the text of the regular expression pattern. Read-only. The regExp argument is a Regular expression object. It can be a variable name or a literal. |
| **`global`**     | <code>boolean</code> | Returns a <a href="#boolean">Boolean</a> value indicating the state of the global flag (g) used with a regular expression. Default is false. Read-only.              |
| **`ignoreCase`** | <code>boolean</code> | Returns a <a href="#boolean">Boolean</a> value indicating the state of the ignoreCase flag (i) used with a regular expression. Default is false. Read-only.          |
| **`multiline`**  | <code>boolean</code> | Returns a <a href="#boolean">Boolean</a> value indicating the state of the multiline flag (m) used with a regular expression. Default is false. Read-only.           |
| **`lastIndex`**  | <code>number</code>  |                                                                                                                                                                      |

| Method      | Signature                                                                     | Description                                                                                                                   |
| ----------- | ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **exec**    | (string: string) =&gt; <a href="#regexpexecarray">RegExpExecArray</a> \| null | Executes a search on a string using a regular expression pattern, and returns an array containing the results of that search. |
| **test**    | (string: string) =&gt; boolean                                                | Returns a <a href="#boolean">Boolean</a> value that indicates whether or not a pattern exists in a searched string.           |
| **compile** | () =&gt; this                                                                 |                                                                                                                               |


#### RegExpExecArray

| Prop        | Type                |
| ----------- | ------------------- |
| **`index`** | <code>number</code> |
| **`input`** | <code>string</code> |


#### Boolean

| Method      | Signature        | Description                                          |
| ----------- | ---------------- | ---------------------------------------------------- |
| **valueOf** | () =&gt; boolean | Returns the primitive value of the specified object. |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |

</docgen-api>
