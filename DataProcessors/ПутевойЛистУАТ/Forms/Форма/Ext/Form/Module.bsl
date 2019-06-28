﻿
Перем Сервис; //подключение к вэб-сервису

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("ДанныеДО") Тогда
		ОбъектГУИД 		= Параметры.ДанныеДО.ОбъектГУИД;
		Проект 			= Параметры.ДанныеДО.ОбъектПроект;
		ОрганизацияИНН 	= Параметры.ДанныеДО.ОбъектОрганизацияИНН;
	КонецЕсли;
	
	Сервис = ВыполнитьПодключение();
	Если Сервис = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПолучитьДанныеДокумента(Сервис, Параметры.ДанныеДО.ЭтоНовыйДокумент);
	ЗаполнитьСписокАвто(Сервис);
	ЗаполнитьСписокЗаправок(Сервис);
	ЗаполнитьСписокВидовТоплива(Сервис);
	ЗаполнитьСписокДвиженийГСМ(Сервис);
	ЗаполнитьСписокКарточки(Сервис);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ДатаДокумента<>Дата(1,1,1) Тогда
		Заголовок = "Путевой лист №"+НомерДокумента+" от "+Формат(ДатаДокумента,"ДФ=dd.MM.yyyy");
	КонецЕсли;	
	РасчетРасходаГСМ();
	ЗаполнениеДопДанных("ПриОткрытии");
	УстановитьОформлениеФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ИсточникВыбора.КлючУникальности = "Выбор авто" Тогда	
		АвтомобильСтрока 	= ВыбранноеЗначение.Представление;	
		АвтомобильКод 		= ВыбранноеЗначение.Значение;
		АвтомобильСтрокаОбработкаВыбораНаСервере();
		ЗаполнениеДопДанных();

	ИначеЕсли ИсточникВыбора.КлючУникальности = "Выбор заправки" Тогда
		ТекСтрока = Элементы.ГСМ.ТекущиеДанные;
		ТекСтрока.Заправка = ВыбранноеЗначение.Представление;
		ТекСтрока.ЗаправкаКод = ВыбранноеЗначение.Значение;
		
	ИначеЕсли ИсточникВыбора.КлючУникальности = "Выбор топлива" Тогда		
		ТекСтрока = Элементы.ГСМ.ТекущиеДанные;
		ТекСтрока.ТипТоплива = ВыбранноеЗначение.Представление;
		ТекСтрока.ТипТопливаКод = ВыбранноеЗначение.Значение;
		
	ИначеЕсли ИсточникВыбора.КлючУникальности = "Выбор оплаты" Тогда		
		ТекСтрока = Элементы.ГСМ.ТекущиеДанные;
		ТекСтрока.ВидДвиженияГСМ = ВыбранноеЗначение.Значение;
		Если ТекСтрока.ВидДвиженияГСМ = "ЗаправкаНаличные" Тогда
			ТекСтрока.ПластиковаяКарта = ""; 
			ТекСтрока.ПластиковаяКартаКод = "";
		КонецЕсли;	
			
	ИначеЕсли ИсточникВыбора.КлючУникальности = "Выбор карточки" Тогда		
		ТекСтрока = Элементы.ГСМ.ТекущиеДанные;
		ТекСтрока.ПластиковаяКарта = ВыбранноеЗначение.Представление;
		ТекСтрока.ПластиковаяКартаКод = ВыбранноеЗначение.Значение;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ЗаписатьЗакрытьНаСервере(ПометкаУдаления = Ложь)
	
	Если НЕ ПометкаУдаления Тогда
	
		Ошибки = ВыполнитьПроверкуЗаполнения();
		Если Ошибки.Количество() > 0 Тогда
			Возврат Ошибки;
		КонецЕсли;
		
	КонецЕсли;	
	
	Сервис = ВыполнитьПодключение();
	
	ПоказанияПриборов = Новый Структура;
	ПоказанияПриборов.Вставить("ОстатокТопливаВыезд"	, ОстатокТопливаВыезд);
	ПоказанияПриборов.Вставить("ОстатокТопливаВозврат"	, ОстатокТопливаВозврат);
	ПоказанияПриборов.Вставить("СпидометрВыезд"			, СпидометрВыезд);
	ПоказанияПриборов.Вставить("СпидометрВозврат"		, СпидометрВозврат);
	
	ДанныеДокумента = Новый Структура;
	ДанныеДокумента.Вставить("ГУИД"					, ОбъектГУИД);
	ДанныеДокумента.Вставить("Автомобиль"			, АвтомобильКод);
	ДанныеДокумента.Вставить("Водитель"				, Водитель);
	ДанныеДокумента.Вставить("ДатаВыезда"			, ПолучитьДатуИзТаблицы("ДатаУбытия", "Возр"));
	ДанныеДокумента.Вставить("ДатаВозвращения"		, ПолучитьДатуИзТаблицы("ДатаПрибытия", "Убыв"));
	ДанныеДокумента.Вставить("Задание"				, Задания.Выгрузить());
	ДанныеДокумента.Вставить("ГСМ"					, ГСМ.Выгрузить());
	ДанныеДокумента.Вставить("Проект"				, Проект);
	ДанныеДокумента.Вставить("ОрганизацияИНН"		, ОрганизацияИНН);
	ДанныеДокумента.Вставить("ПоказанияПриборов"	, ПоказанияПриборов);
	ДанныеДокумента.Вставить("ПометкаУдаления"		, ПометкаУдаления);

	Сериализатор = Новый СериализаторXDTO(ФабрикаXDTO);
	ПараметрыОбъектаXDTO = Сериализатор.ЗаписатьXDTO(ДанныеДокумента);
	
	СтрокаВозврата = Сервис.SaveData(ПараметрыОбъектаXDTO);
	
	Возврат СтрокаВозврата;
	
КонецФункции

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьЗакрыть(Команда)
	
	СтрокаВозврата = ЗаписатьЗакрытьНаСервере();
	
	Если Лев(СтрокаВозврата,1) = "{" Тогда
		//JSON
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(СтрокаВозврата);
		СтруктураОтвета = ПрочитатьJSON(ЧтениеJSON);
		
		НомерДокумента	= СтруктураОтвета.Номер;
		ДатаДокумента 	= ПрочитатьДатуJSON(СтруктураОтвета.Дата, ФорматДатыJSON.ISO);	
		Ошибки 			= СтруктураОтвета.Ошибки;	
		
		ОповеститьОВыборе(Новый Структура("Автомобиль, Номер, Дата, ИД", АвтомобильСтрока, НомерДокумента, ДатаДокумента, ОбъектГУИД));
	Иначе
		Сообщить("Прервано из-за ошибок!", СтатусСообщения.ОченьВажное);
		ПоказатьОшибки(СтрокаВозврата);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Записать(Команда)
	
	СтрокаВозврата = ЗаписатьЗакрытьНаСервере();
	
	Если Лев(СтрокаВозврата,1) = "{" Тогда
		//JSON
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(СтрокаВозврата);
		СтруктураОтвета = ПрочитатьJSON(ЧтениеJSON);
		
		НомерДокумента	= СтруктураОтвета.Номер;
		ДатаДокумента 	= ПрочитатьДатуJSON(СтруктураОтвета.Дата, ФорматДатыJSON.ISO);	
		Ошибки 			= СтруктураОтвета.Ошибки;	
		
		ОповеститьОЗаписиНового(Новый Структура("Автомобиль, Номер, Дата, ИД", АвтомобильСтрока, НомерДокумента, ДатаДокумента, ОбъектГУИД));
	Иначе
		Сообщить("Прервано из-за ошибок!", СтатусСообщения.ОченьВажное);
		ПоказатьОшибки(СтрокаВозврата);
	КонецЕсли;

	
КонецПроцедуры

&НаСервере
Функция СформироватьПечатнуюФорму(ОбъектГУИД)
	
	Сервис = ВыполнитьПодключение();
	Если Сервис = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТабДокумент = Сервис.PrintData(ОбъектГУИД);
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла();		
	ДвоичныеДанные = ЗначениеИзСтрокиВнутр(ТабДокумент.Data);
	ДвоичныеДанные.Записать(ИмяВременногоФайла);
	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.Прочитать(ИмяВременногоФайла);
	
	Возврат ТабДокумент;

КонецФункции

&НаКлиенте
Процедура Печать(Команда)
	
	Если ОбъектГУИД = "" Тогда
		Возврат;
	КонецЕсли;
	
	ТабДокумент = СформироватьПечатнуюФорму(ОбъектГУИД);
	
	Если ТабДокумент<>Неопределено Тогда
					
		ИдентификаторПечатнойФормы = "ПутевойЛист";
		НазваниеПечатнойФормы = НСтр("ru = 'Путевой лист'");
				
		МодульУправлениеПечатьюКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("УправлениеПечатьюКлиент");
		
		КоллекцияПечатныхФорм = МодульУправлениеПечатьюКлиент.НоваяКоллекцияПечатныхФорм(ИдентификаторПечатнойФормы);
		ПечатнаяФорма = МодульУправлениеПечатьюКлиент.ОписаниеПечатнойФормы(КоллекцияПечатныхФорм, ИдентификаторПечатнойФормы);
		ПечатнаяФорма.СинонимМакета = НазваниеПечатнойФормы;
		ПечатнаяФорма.ТабличныйДокумент = ТабДокумент;
		ПечатнаяФорма.ИмяФайлаПечатнойФормы = НазваниеПечатнойФормы;
		
		ОбластиОбъектов = Новый СписокЗначений;
		МодульУправлениеПечатьюКлиент.ПечатьДокументов(КоллекцияПечатныхФорм, ОбластиОбъектов);

	КонецЕсли;	

КонецПроцедуры

&НаКлиенте
Процедура УдалитьДокумент(Команда)
	
	Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопросаНаУдаление", ЭтотОбъект);	
 
    ПоказатьВопрос(Оповещение,
        "Удалить данный путевой лист?",
        РежимДиалогаВопрос.ДаНетОтмена,
        0, // таймаут в секундах
        КодВозвратаДиалога.Да, // (необ.) кнопка по умолчанию
        "Удаление документа" // (необ.) заголовок
    );    
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияВопросаНаУдаление(Результат, Параметры) Экспорт
 
    Если Результат = КодВозвратаДиалога.Да Тогда
		СтрокаВозврата = ЗаписатьЗакрытьНаСервере(Истина);
		
		Если Лев(СтрокаВозврата,1) = "{" Тогда
			//JSON
			ЧтениеJSON = Новый ЧтениеJSON;
			ЧтениеJSON.УстановитьСтроку(СтрокаВозврата);
			СтруктураОтвета = ПрочитатьJSON(ЧтениеJSON);		
			ПометкаУдаленияПЛ = СтруктураОтвета.ПометкаУдаления;
			Если ПометкаУдаленияПЛ Тогда
				ОповеститьОВыборе(Новый Структура("ПометкаУдаления, ИД", ПометкаУдаленияПЛ, ОбъектГУИД));
			Иначе
				Сообщить("Прервано из-за ошибок!", СтатусСообщения.ОченьВажное);
				ПоказатьОшибки(СтруктураОтвета.Ошибки);
			КонецЕсли;	
		Иначе
			Сообщить("Прервано из-за ошибок!", СтатусСообщения.ОченьВажное);
			ПоказатьОшибки(СтрокаВозврата);
		КонецЕсли;
		
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура АвтомобильНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыбратьЗначениеИзСписка(СписокАвто, "Выбор авто");
	
КонецПроцедуры

&НаСервере
Процедура АвтомобильСтрокаОбработкаВыбораНаСервере()
	
	Если Сервис = Неопределено Тогда
		Сервис = ВыполнитьПодключение();
	КонецЕсли;
	
	Если Сервис = Неопределено Тогда
		//ОстатокТопливаВыезд = 0;
		Возврат;
	КонецЕсли;
	
	//ОстатокТопливаВыезд = Сервис.GetCountFuelStart(АвтомобильКод);
	
КонецПроцедуры

&НаКлиенте
Процедура ОстатокТопливаВыездПриИзменении(Элемент)
	РасчетРасходаГСМ();
КонецПроцедуры

&НаКлиенте
Процедура ОстатокТопливаВозвратПриИзменении(Элемент)
	РасчетРасходаГСМ();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийТаблицыЗадания

&НаКлиенте
Процедура ЗаданияПробегПриИзменении(Элемент)
	РасчетРасходаГСМ();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийТаблицыГСМ


&НаКлиенте
Процедура ГСМЗаправкаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыбратьЗначениеИзСписка(СписокЗаправок, "Выбор заправки");

КонецПроцедуры

&НаКлиенте
Процедура ГСМТипТопливаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыбратьЗначениеИзСписка(СписокТиповТоплива, "Выбор топлива");
	
КонецПроцедуры

&НаКлиенте
Процедура ГСМВидДвиженияГСМНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыбратьЗначениеИзСписка(СписокДвиженияГСМ, "Выбор оплаты");
	
КонецПроцедуры

&НаКлиенте
Процедура ГСМПластиковаяКартаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ТекСтрока = Элементы.ГСМ.ТекущиеДанные;
	Если ТекСтрока.ВидДвиженияГСМ = "ЗаправкаНаличные" Тогда
		Возврат;
	КонецЕсли;	
	ВыбратьЗначениеИзСписка(СписокПластиковыхКарт, "Выбор карточки");
	
КонецПроцедуры

&НаКлиенте
Процедура ГСМЗаправкаАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	УстановитьАвтоОтбор(СписокЗаправок, Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
КонецПроцедуры

&НаКлиенте
Процедура ГСМТипТопливаАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	УстановитьАвтоОтбор(СписокТиповТоплива, Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
КонецПроцедуры

&НаКлиенте
Процедура ГСМВидДвиженияГСМАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	УстановитьАвтоОтбор(СписокДвиженияГСМ, Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
КонецПроцедуры

&НаКлиенте
Процедура ГСМПластиковаяКартаАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	УстановитьАвтоОтбор(СписокПластиковыхКарт, Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)	
КонецПроцедуры

&НаКлиенте
Процедура ГСМЗаправкаОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = СписокЗаправок;	
КонецПроцедуры

&НаКлиенте
Процедура ГСМТипТопливаОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = СписокТиповТоплива;
КонецПроцедуры

&НаКлиенте
Процедура ГСМВидДвиженияГСМОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = СписокДвиженияГСМ;
КонецПроцедуры

&НаКлиенте
Процедура ГСМПластиковаяКартаОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = СписокПластиковыхКарт;
КонецПроцедуры

&НаКлиенте
Процедура ГСМЗаправкаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	ГСМОбработкаВыбораПолей(СписокЗаправок, ВыбранноеЗначение, СтандартнаяОбработка, "ЗаправкаКод", "Заправка");
	
КонецПроцедуры

&НаКлиенте
Процедура ГСМТипТопливаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ГСМОбработкаВыбораПолей(СписокТиповТоплива, ВыбранноеЗначение, СтандартнаяОбработка, "ТипТопливаКод", "ТипТоплива");
КонецПроцедуры

&НаКлиенте
Процедура ГСМВидДвиженияГСМОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ГСМОбработкаВыбораПолей(СписокДвиженияГСМ, ВыбранноеЗначение, СтандартнаяОбработка, , "ВидДвиженияГСМ");
КонецПроцедуры

&НаКлиенте
Процедура ГСМПластиковаяКартаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ГСМОбработкаВыбораПолей(СписокПластиковыхКарт, ВыбранноеЗначение, СтандартнаяОбработка, "ПластиковаяКартаКод", "ПластиковаяКарта");
КонецПроцедуры

&НаКлиенте
Процедура УстановитьАвтоОтбор(СписокЭлементов, Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	Если Ожидание<>0 И СтрДлина(Текст)>=3 Тогда
		СтандартнаяОбработка = Ложь;
		РезультатПоиска = ОтборПоСписку(Текст, СписокЭлементов);
		ДанныеВыбора = РезультатПоиска;
	КонецЕсли;
	
КонецПроцедуры	

&НаКлиенте
Процедура ГСМОбработкаВыбораПолей(СписокЭлементов = Неопределено, ВыбранноеЗначение, СтандартнаяОбработка, КолонкаЗначение = "", КолонкаПредставление)
	
	ТекСтрока = Элементы.ГСМ.ТекущиеДанные;
	Если ТипЗнч(ВыбранноеЗначение) = Тип("ЭлементСпискаЗначений") И КолонкаЗначение<>"" Тогда
		Если ТекСтрока.ВидДвиженияГСМ = "ЗаправкаНаличные" И КолонкаПредставление = "ПластиковаяКарта" Тогда
			//если оплата наличными, то карта не нужна
			СтандартнаяОбработка = Ложь;
			Возврат;
		КонецЕсли;
		ТекСтрока[КолонкаЗначение] = ВыбранноеЗначение.Значение;
		
	ИначеЕсли ТипЗнч(ВыбранноеЗначение) = Тип("Строка") Тогда
		Если ТекСтрока.ВидДвиженияГСМ = "ЗаправкаНаличные" И КолонкаПредставление = "ПластиковаяКарта" Тогда
			//если оплата наличными, то карта не нужна
			ВыбранноеЗначение = "";
		КонецЕсли;	
		ИскСтрока = СписокЭлементов.НайтиПоЗначению(ВыбранноеЗначение);
		Если ИскСтрока<>Неопределено Тогда
			СтандартнаяОбработка = Ложь;
			ТекСтрока[КолонкаПредставление] = ИскСтрока.Представление;
			Если КолонкаЗначение<>"" Тогда
				ТекСтрока[КолонкаЗначение] = ИскСтрока.Значение;
			КонецЕсли;	
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры	

&НаКлиенте
Процедура ГСМВидДвиженияГСМПриИзменении(Элемент)
	
	ТекСтрока = Элементы.ГСМ.ТекущиеДанные;
	Если ТекСтрока.ВидДвиженияГСМ = "ЗаправкаНаличные" Тогда
		ТекСтрока.ГСМПластиковаяКарта = "";
		ТекСтрока.ГСМПластиковаяКод = "";
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ГСМКоличествоПриИзменении(Элемент)
	РасчетСуммыЗаправки();
	РасчетРасходаГСМ();
КонецПроцедуры

&НаКлиенте
Процедура ГСМЦенаПриИзменении(Элемент)
	РасчетСуммыЗаправки();
КонецПроцедуры

&НаКлиенте
Процедура ГСМСуммаПриИзменении(Элемент)
	
	ТекСтрока = Элементы.ГСМ.ТекущиеДанные;
	ТекСтрока.Цена = ?(ТекСтрока.Количество = 0, 0, ТекСтрока.Сумма / ТекСтрока.Количество);

КонецПроцедуры

&НаКлиенте
Процедура РасчетСуммыЗаправки()
	
	ТекСтрока = Элементы.ГСМ.ТекущиеДанные;
	ТекСтрока.Сумма = ТекСтрока.Цена * ТекСтрока.Количество;
	РасчетРасходаГСМ();
	
КонецПроцедуры	

&НаКлиенте
Процедура ГСМПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Если Копирование Тогда
		Отказ = Истина;		
		НСтрока = ГСМ.Добавить();
		ЗаполнитьЗначенияСвойств(НСтрока, Элемент.ТекущиеДанные, ,"ГУИД");
	КонецЕсли;	
		
КонецПроцедуры

&НаКлиенте
Процедура ГСМПередУдалением(Элемент, Отказ)
	Отказ = Истина;
КонецПроцедуры

#КонецОбласти

#Область ОбменСВебСервисом

&НаСервере
Функция ВыполнитьПодключение()
	
	//УстановитьБезопасныйРежим(Ложь);
	
	//Создание WS-прокси на основании ссылки
	Пользователь = "web";
	Пароль = "123";
	
	//Определение = Новый WSОпределения("http://127.0.0.1/uat/ws/wldata.1cws?wsdl", Пользователь, Пароль);
	Определение = Новый WSОпределения("http://1c.ate.net.ru:88/uat/ws/wldata.1cws?wsdl", Пользователь, Пароль);
	Сервис = Новый WSПрокси(Определение, "http://it-ing.ru", "WayListData", "WayListDataSoap");
	Сервис.Пользователь = Пользователь;
	Сервис.Пароль = Пароль;

	Возврат Сервис;
	
КонецФункции

&НаСервере
Процедура ПолучитьДанныеДокумента(Сервис, ЭтоНовыйДокумент)
	
	Если ЭтоНовыйДокумент Тогда
		Водитель = ПараметрыСеанса.ТекущийПользователь.ФизЛицо.Наименование;
		Возврат;
	КонецЕсли;
		
	ДанныеДокумента = Сервис.GetData(ОбъектГУИД);
	Если ДанныеДокумента = Неопределено Тогда
		//Значит документ не нашли
		Водитель = ПараметрыСеанса.ТекущийПользователь.ФизЛицо.Наименование;
		Возврат;
	КонецЕсли;
	
	НомерДокумента   = ДанныеДокумента.Number;
	ДатаДокумента 	 = ДанныеДокумента.Date;
	АвтомобильСтрока = ДанныеДокумента.Auto.Name;
	АвтомобильКод	 = ДанныеДокумента.Auto.ID;
	Водитель		 = ДанныеДокумента.Driver;
	
	ОстатокТопливаВыезд 	= ДанныеДокумента.CountFuelStart;
	ОстатокТопливаВозврат 	= ДанныеДокумента.CountFuelEnd;
	СпидометрВыезд			= ДанныеДокумента.SpeedometrStart;
	СпидометрВозврат		= ДанныеДокумента.SpeedometrEnd;
	
	Для Каждого Стр Из ДанныеДокумента.Tasks Цикл
		НСтрока = Задания.Добавить();
		НСтрока.АдресУбытия 	= Стр.StartPoint;
		НСтрока.АдресПрибытия 	= Стр.StopPoint;
		НСтрока.ДатаУбытия 		= Стр.StartDate;
		НСтрока.ДатаПрибытия	= Стр.StopDate;
		НСтрока.Пробег			= Стр.Run;
	КонецЦикла;
	
	Для Каждого Стр Из ДанныеДокумента.GasStations Цикл
		НСтрока = ГСМ.Добавить();
		НСтрока.Дата 			= Стр.Date;
		НСтрока.Заправка 		= Стр.GasStation.Name;
		НСтрока.ТипТоплива 		= Стр.Fuel.Name;
		НСтрока.Цена 			= Стр.Price;
		НСтрока.Сумма 			= Стр.Total;
		НСтрока.Количество 		= Стр.Quantity;
		НСтрока.ВидДвиженияГСМ  = Стр.MotionFuel.Name;
		НСтрока.ЗаправкаКод		= Стр.GasStation.ID;
		НСтрока.ТипТопливаКод	= Стр.Fuel.ID;
		НСтрока.ГУИД			= Стр.ID;
		НСтрока.ПластиковаяКарта	 = Стр.Card.Name;
		НСтрока.ПластиковаяКартаКод	 = Стр.Card.ID;		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокАвто(Сервис)
	
	АвтомобилиУАТ = Сервис.GetAuto();
	
	Для Каждого Сч Из АвтомобилиУАТ.Auto Цикл
		СписокАвто.Добавить(Сч.ID, Сч.Name);
		
		НСтрока = ХарактеристикиАвто.Добавить();
		НСтрока.VIN = "VIN_"+Сч.ID;
		НСтрока.РасходГСМпоНорме = Сч.ExpenseFuelNorm; 
		НСтрока.СпидометрВыезд = Сч.SpidometrEnd; //последнее значение по возвращению
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокЗаправок(Сервис)
	
	ЗаправкиУАТ = Сервис.GetGasStation();
	
	Для Каждого Сч Из ЗаправкиУАТ.GasStation Цикл
		СписокЗаправок.Добавить(Сч.ID, Сч.Name);
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокВидовТоплива(Сервис)
	
	ТипыТопливаУАТ = Сервис.GetFuel();
	
	Для Каждого Сч Из ТипыТопливаУАТ.Fuel Цикл
		СписокТиповТоплива.Добавить(Сч.ID, Сч.Name);
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокДвиженийГСМ(Сервис)
	
	ВидыДвиженияГСМ = Сервис.GetMotionFuel();
	
	Для Каждого Сч Из ВидыДвиженияГСМ.MotionFuel Цикл
		СписокДвиженияГСМ.Добавить(Сч.ID, Сч.ID);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокКарточки(Сервис)
	
	КарточкиУАТ = Сервис.GetCard();
	
	Для Каждого Сч Из КарточкиУАТ.Card Цикл
		СписокПластиковыхКарт.Добавить(Сч.ID, Сч.Name);
	КонецЦикла;	
	
КонецПроцедуры

#КонецОбласти

#Область ДополнительныеОбработчики

&НаКлиенте
Процедура УстановитьОформлениеФормы()
	
	//если расход по факту больше на 15%
	Если РасходГСМпоНорме>0 Тогда
		Элементы.РасходГСМпоФакту.ЦветТекста = ?(РасходГСМпоФакту >= РасходГСМпоНорме + 15 * РасходГСМпоНорме / 100 , WEBЦвета.Красный, WEBЦвета.Зеленый);
	КонецЕсли;
	
КонецПроцедуры


&НаСервере
Функция ВыполнитьПроверкуЗаполнения()
	
	Ошибки = Новый Массив;
	
	Если Не ЗначениеЗаполнено(АвтомобильСтрока) Тогда
		Ошибки.Добавить("Не выбран автомобиль!");
	КонецЕсли;
	
	Для Каждого Стр Из Задания Цикл
		Если Стр.ДатаПрибытия < Стр.ДатаУбытия Тогда
			Ошибки.Добавить("Дата прибытия <"+Стр.ДатаПрибытия+"> не может быть меньше даты убытия <"+Стр.ДатаУбытия+">");
		КонецЕсли;
	КонецЦикла;
	
	КолонкиБезПроверки = Новый Массив;
	КолонкиБезПроверки.Добавить("ГУИД");
	КолонкиБезПроверки.Добавить("ПластиковаяКарта");
	КолонкиБезПроверки.Добавить("ПластиковаяКартаКод");
	КолонкиБезПроверки.Добавить("Цена");
	КолонкиБезПроверки.Добавить("Сумма");
	
	Для Каждого Стр Из ГСМ Цикл
		Для Каждого Колонка Из ГСМ.Выгрузить().Колонки Цикл
			Если Не ЗначениеЗаполнено(Стр[Колонка.Имя]) И КолонкиБезПроверки.Найти(Колонка.Имя) = Неопределено Тогда
				Ошибки.Добавить("Не заполнена колонка <"+Колонка.Имя+"> в таблице ГСМ");
			КонецЕсли;
		КонецЦикла;
		
		Если Стр.ВидДвиженияГСМ = "ЗаправкаПластиковаяКарта" И Не ЗначениеЗаполнено(Стр.ПластиковаяКарта) Тогда
			Ошибки.Добавить("Не выбрана пластиковая карта в таблице ГСМ");			
		КонецЕсли;
		
	КонецЦикла;
	
	Если ОстатокТопливаВыезд = 0 Тогда
		Ошибки.Добавить("Не заполнен остаток ГСМ при получении!");
	КонецЕсли;

	Если СпидометрВыезд = 0 ИЛИ СпидометрВозврат = 0 Тогда
		Ошибки.Добавить("Не заполнены показания одометра!");
	КонецЕсли;
		
	Если СпидометрВыезд >= СпидометрВозврат Тогда
		Ошибки.Добавить("Неверно установлены показания одометра!");
	КонецЕсли;
		
	Возврат Ошибки;
	
КонецФункции

&НаКлиенте
Процедура ВыбратьЗначениеИзСписка(Список, УникальныйКлюч)
	
	СтандартнаяОбработка = Ложь;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Список", Список);
	ПараметрыФормы.Вставить("ЗакрыватьПриВыборе", Истина);
	
	ОткрытьФорму("Обработка.ПутевойЛистУАТ.Форма.ФормаВыбораЗначения", ПараметрыФормы, ЭтаФорма, УникальныйКлюч);
	
КонецПроцедуры

&НаСервере
Функция ПолучитьДатуИзТаблицы(КолонкаПоиска, ТипСортировки)
	
	Если Задания.Количество() = 0 Тогда
		Возврат ТекущаяДата();
	КонецЕсли;
	
	ВремТЗ = Задания.Выгрузить(,КолонкаПоиска);
	Сортировка = КолонкаПоиска+" "+ТипСортировки;
	ВремТЗ.Сортировать(Сортировка);
	Возврат ВремТЗ[0][КолонкаПоиска];
	
КонецФункции

&НаКлиенте
Функция ПоказатьОшибки(Ошибки)
	
	Если ТипЗнч(Ошибки) = Тип("Строка") Тогда
		Сообщить(Ошибки, СтатусСообщения.Важное);
	Иначе	
		Для Каждого Сч Из Ошибки Цикл
			Сообщить(Сч, СтатусСообщения.Важное);
		КонецЦикла;
	КонецЕсли;	
	
КонецФункции

&НаКлиенте
Функция ОтборПоСписку(СтрокаПоиска, СписокЭлементов)
	
	РезультатПоиска = Новый СписокЗначений;
	Для Каждого Стр Из СписокЭлементов Цикл
		Если Найти(НРег(Стр.Представление), НРег(СтрокаПоиска))>0 Тогда
			РезультатПоиска.Добавить(Стр);
		КонецЕсли;
	КонецЦикла;	
			
	Возврат РезультатПоиска;
		
КонецФункции	

&НаКлиенте
Процедура РасчетРасходаГСМ()
	
	Если Задания.Итог("Пробег")>0 Тогда
		РасходГСМпоФакту = (ОстатокТопливаВыезд + ГСМ.Итог("Количество") - ОстатокТопливаВозврат) * 100 / Задания.Итог("Пробег");
	КонецЕсли;
	ОбщийПробег = Задания.Итог("Пробег");
	УстановитьОформлениеФормы();
	
КонецПроцедуры	

&НаКлиенте
Процедура ЗаполнениеДопДанных(Событие = "")
	
	ИскАвто = ХарактеристикиАвто.НайтиСтроки(Новый Структура("VIN", "VIN_"+АвтомобильКод));
	Если ИскАвто.Количество()>0 Тогда
		РасходГСМпоНорме = ИскАвто[0].РасходГСМпоНорме;
		
		//если при открытии, то не меняем
		Если Событие = "" Тогда
			СпидометрВыезд = ИскАвто[0].СпидометрВыезд;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти











