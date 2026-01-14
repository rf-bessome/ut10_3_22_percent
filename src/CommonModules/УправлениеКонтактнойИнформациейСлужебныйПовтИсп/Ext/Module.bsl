///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Преобразование для текста с парами Ключ=Значение, разделенных переносами строк (см формат адреса) в XML.
// В случае повторных ключей все включаются в результат, но при десериализации будет использован 
// последний (особенность работы сериализатора платформы).
//
// Возвращаемое значение:
//     ПреобразованиеXSL  - подготовленный объект.
//
Функция XSLT_СтрокаКлючЗначениеВСтруктуру() Экспорт
	Преобразователь = Новый ПреобразованиеXSL;
	Преобразователь.ЗагрузитьИзСтроки("
		|<xsl:stylesheet version=""1.0""
		|  xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""
		|  xmlns:str=""http://exslt.org/strings""
		|  extension-element-prefixes=""str""
		|>
		|<xsl:output method=""xml"" omit-xml-declaration=""yes"" indent=""yes"" encoding=""utf-8""/>
		|" + XSLT_ШаблоныСтроковыхФункций() + "
		|
		|  <xsl:template match=""ExternalParamNode"">
		|
		|    <xsl:variable name=""source"">
		|      <xsl:call-template name=""str-replace-all"">
		|        <xsl:with-param name=""str"" select=""."" />
		|        <xsl:with-param name=""search-for"" select=""'&#10;&#09;'"" />
		|        <xsl:with-param name=""replace-by"" select=""'&#13;'"" />
		|      </xsl:call-template>
		|    </xsl:variable>
		|
		|    <Structure xmlns=""http://v8.1c.ru/8.1/data/core"" xmlns:xs=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:type=""Structure"">
		|
		|     <xsl:for-each select=""str:tokenize($source, '&#10;')"" >
		|       <xsl:if test=""contains(., '=')"">
		|
		|         <xsl:element name=""Property"">
		|           <xsl:attribute name=""name"" >
		|             <xsl:call-template name=""str-trim-all"">
		|               <xsl:with-param name=""str"" select=""substring-before(., '=')"" />
		|             </xsl:call-template>
		|           </xsl:attribute>
		|
		|           <Value xsi:type=""xs:string"">
		|             <xsl:call-template name=""str-replace-all"">
		|               <xsl:with-param name=""str"" select=""substring-after(., '=')"" />
		|               <xsl:with-param name=""search-for"" select=""'&#13;'"" />
		|               <xsl:with-param name=""replace-by"" select=""'&#10;'"" />
		|             </xsl:call-template>
		|           </Value>
		|
		|         </xsl:element>
		|
		|       </xsl:if>
		|     </xsl:for-each>
		|
		|    </Structure>
		|
		|  </xsl:template>
		|
		|</xsl:stylesheet>
		|");

	Возврат Преобразователь;
КонецФункции

// Преобразование для списка значений в структуру. Представление преобразуется в ключ.
//
// Возвращаемое значение:
//     ПреобразованиеXSL  - подготовленный объект.
//
Функция XSLT_СписокЗначенийВСтруктуру() Экспорт
	Преобразователь = Новый ПреобразованиеXSL;
	Преобразователь.ЗагрузитьИзСтроки("
		|<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""
		|  xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""
		|  xmlns:tns=""http://v8.1c.ru/8.1/data/core""
		|  xmlns=""http://v8.1c.ru/8.1/data/core""
		|>
		|<xsl:output method=""xml"" omit-xml-declaration=""yes"" indent=""yes"" encoding=""utf-8""/>
		|" + XSLT_ШаблоныСтроковыхФункций() + "
		|
		|  <xsl:template match=""/"">
		|    <Structure xmlns=""http://v8.1c.ru/8.1/data/core"" xmlns:xs=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:type=""Structure"">
		|      <xsl:apply-templates select=""//tns:ValueListType/tns:item"" />
		|    </Structure >
		|  </xsl:template>
		|
		|  <xsl:template match=""//tns:ValueListType/tns:item"">
		|    <xsl:element name=""Property"">
		|      <xsl:attribute name=""name"">
		|        <xsl:call-template name=""str-trim-all"">
		|          <xsl:with-param name=""str"" select=""tns:presentation"" />
		|        </xsl:call-template>
		|      </xsl:attribute>
		|
		|      <xsl:element name=""Value"">
		|        <xsl:attribute name=""xsi:type"">
		|          <xsl:value-of select=""tns:value/@xsi:type""/>  
		|        </xsl:attribute>
		|        <xsl:value-of select=""tns:value""/>  
		|      </xsl:element>
		|
		|    </xsl:element>
		|</xsl:template>
		|
		|</xsl:stylesheet>
		|");
	Возврат Преобразователь;
КонецФункции

// Преобразование для соответствия в структуру. Ключ преобразуется в ключ, значение - в значение.
//
// Возвращаемое значение:
//     ПреобразованиеXSL  - подготовленный объект.
//
Функция XSLT_СоответствиеВСтруктуру() Экспорт
	Преобразователь = Новый ПреобразованиеXSL;
	Преобразователь.ЗагрузитьИзСтроки("
		|<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""
		|  xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""
		|  xmlns:tns=""http://v8.1c.ru/8.1/data/core""
		|  xmlns=""http://v8.1c.ru/8.1/data/core""
		|>
		|<xsl:output method=""xml"" omit-xml-declaration=""yes"" indent=""yes"" encoding=""utf-8""/>
		|" + XSLT_ШаблоныСтроковыхФункций() + "
		|
		|  <xsl:template match=""/"">
		|    <Structure xmlns=""http://v8.1c.ru/8.1/data/core"" xmlns:xs=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:type=""Structure"">
		|      <xsl:apply-templates select=""//tns:Map/tns:pair"" />
		|    </Structure >
		|  </xsl:template>
		|  
		|  <xsl:template match=""//tns:Map/tns:pair"">
		|  <xsl:element name=""Property"">
		|    <xsl:attribute name=""name"">
		|      <xsl:call-template name=""str-trim-all"">
		|        <xsl:with-param name=""str"" select=""tns:Key"" />
		|      </xsl:call-template>
		|    </xsl:attribute>
		|  
		|    <xsl:element name=""Value"">
		|      <xsl:attribute name=""xsi:type"">
		|        <xsl:value-of select=""tns:Value/@xsi:type""/>  
		|      </xsl:attribute>
		|        <xsl:value-of select=""tns:Value""/>  
		|      </xsl:element>
		|  
		|    </xsl:element>
		|  </xsl:template>
		|
		|</xsl:stylesheet>
		|");
	Возврат Преобразователь;
КонецФункции

// Возвращает преобразователь XSL для конвертации структуры в контактную информацию в виде XML.
//
// Возвращаемое значение:
//     ПреобразованиеXSL  - подготовленный объект.
//
Функция XSLT_ПреобразованиеXSL() Экспорт
	
	КодыДополнительныхАдресныхЭлементов = Новый ТекстовыйДокумент;
	Для Каждого ДополнительныйАдресныйЭлемент Из УправлениеКонтактнойИнформациейКлиентСерверПовтИсп.ТипыОбъектовАдресацииАдресаРФ() Цикл
		КодыДополнительныхАдресныхЭлементов.ДобавитьСтроку("<data:item data:title=""" + ДополнительныйАдресныйЭлемент.Наименование + """>" + ДополнительныйАдресныйЭлемент.Код + "</data:item>");
	КонецЦикла;
	
	КодыРегионов = Новый ТекстовыйДокумент;
	ВсеРегионы = УправлениеКонтактнойИнформациейСлужебный.ВсеРегионы();
	Если ВсеРегионы <> Неопределено Тогда
		Для Каждого Строка Из ВсеРегионы Цикл
			КодыРегионов.ДобавитьСтроку("<data:item data:code=""" + Формат(Строка.КодСубъектаРФ, "ЧН=; ЧГ=") + """>" 
				+ Строка.Представление + "</data:item>");
		КонецЦикла;
	КонецЕсли;
	
	Преобразователь = Новый ПреобразованиеXSL;
	Преобразователь.ЗагрузитьИзСтроки("
		|<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""
		|  xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""
		|  xmlns:xs=""http://www.w3.org/2001/XMLSchema""
		|  xmlns:tns=""http://v8.1c.ru/8.1/data/core""
		|  xmlns=""http://www.v8.1c.ru/ssl/contactinfo"" 
		|
		|  xmlns:data=""http://www.v8.1c.ru/ssl/contactinfo""
		|
		|  xmlns:exsl=""http://exslt.org/common""
		|  extension-element-prefixes=""exsl""
		|  exclude-result-prefixes=""data tns""
		|>
		|<xsl:output method=""xml"" omit-xml-declaration=""yes"" indent=""yes"" encoding=""utf-8""/>
		|  " + XSLT_ШаблоныСтроковыхФункций() + "
		|  
		|  <xsl:variable name=""local-country"">РОССИЯ</xsl:variable>
		|
		|  <xsl:variable name=""presentation"" select=""tns:Structure/tns:Property[@name='Представление']/tns:Value/text()"" />
		|  
		|  <xsl:template match=""/"">
		|    <КонтактнаяИнформация>
		|
		|      <xsl:attribute name=""Представление"">
		|        <xsl:value-of select=""$presentation""/>
		|      </xsl:attribute> 
		|      <xsl:element name=""Комментарий"">
		|       <xsl:value-of select=""tns:Structure/tns:Property[@name='Комментарий']/tns:Value/text()""/>
		|      </xsl:element>
		|
		|      <xsl:element name=""Состав"">
		|        <xsl:attribute name=""xsi:type"">Адрес</xsl:attribute>
		|        <xsl:variable name=""country"" select=""tns:Structure/tns:Property[@name='Страна']/tns:Value/text()""></xsl:variable>
		|        <xsl:variable name=""country-upper"">
		|          <xsl:call-template name=""str-upper"">
		|            <xsl:with-param name=""str"" select=""$country"" />
		|          </xsl:call-template>
		|        </xsl:variable>
		|
		|        <xsl:attribute name=""Страна"">
		|          <xsl:choose>
		|            <xsl:when test=""0=count($country)"">
		|              <xsl:value-of select=""$local-country"" />
		|            </xsl:when>
		|            <xsl:otherwise>
		|              <xsl:value-of select=""$country"" />
		|            </xsl:otherwise> 
		|          </xsl:choose>
		|        </xsl:attribute>
		|
		|        <xsl:choose>
		|          <xsl:when test=""0=count($country)"">
		|            <xsl:apply-templates select=""/"" mode=""domestic"" />
		|          </xsl:when>
		|          <xsl:when test=""$country-upper=$local-country"">
		|            <xsl:apply-templates select=""/"" mode=""domestic"" />
		|          </xsl:when>
		|          <xsl:otherwise>
		|            <xsl:apply-templates select=""/"" mode=""foreign"" />
		|          </xsl:otherwise> 
		|        </xsl:choose>
		|
		|      </xsl:element>
		|    </КонтактнаяИнформация>
		|  </xsl:template>
		|  
		|  <xsl:template match=""/"" mode=""foreign"">
		|    <xsl:element name=""Состав"">
		|      <xsl:attribute name=""xsi:type"">xs:string</xsl:attribute>
		|
		|      <xsl:variable name=""value"" select=""tns:Structure/tns:Property[@name='Значение']/tns:Value/text()"" />        
		|      <xsl:choose>
		|        <xsl:when test=""0=count($value)"">
		|          <xsl:value-of select=""$presentation"" />
		|        </xsl:when>
		|        <xsl:otherwise>
		|          <xsl:value-of select=""$value"" />
		|        </xsl:otherwise> 
		|      </xsl:choose>
		|    
		|    </xsl:element>
		|  </xsl:template>
		|  
		|  <xsl:template match=""/"" mode=""domestic"">
		|    <xsl:element name=""Состав"">
		|      <xsl:attribute name=""xsi:type"">АдресРФ</xsl:attribute>
		|    
		|      <xsl:element name=""СубъектРФ"">
		|        <xsl:variable name=""value"" select=""tns:Structure/tns:Property[@name='Регион']/tns:Value/text()"" />
		|
		|        <xsl:choose>
		|          <xsl:when test=""0=count($value)"">
		|            <xsl:variable name=""regioncode"" select=""tns:Structure/tns:Property[@name='КодРегиона']/tns:Value/text()""/>
		|            <xsl:variable name=""regiontitle"" select=""$enum-regioncode-nodes/data:item[@data:code=number($regioncode)]"" />
		|              <xsl:if test=""0!=count($regiontitle)"">
		|                <xsl:value-of select=""$regiontitle""/>
		|              </xsl:if>
		|          </xsl:when>
		|          <xsl:otherwise>
		|            <xsl:value-of select=""$value"" />
		|          </xsl:otherwise> 
		|        </xsl:choose>
		|
		|      </xsl:element>
		|   
		|      <xsl:element name=""Округ"">
		|        <xsl:value-of select=""tns:Structure/tns:Property[@name='Округ']/tns:Value/text()""/>
		|      </xsl:element>
		|
		|      <xsl:element name=""СвРайМО"">
		|        <xsl:element name=""Район"">
		|          <xsl:value-of select=""tns:Structure/tns:Property[@name='Район']/tns:Value/text()""/>
		|        </xsl:element>
		|      </xsl:element>
		|  
		|      <xsl:element name=""Город"">
		|        <xsl:value-of select=""tns:Structure/tns:Property[@name='Город']/tns:Value/text()""/>
		|      </xsl:element>
		|    
		|      <xsl:element name=""ВнутригРайон"">
		|        <xsl:value-of select=""tns:Structure/tns:Property[@name='ВнутригРайон']/tns:Value/text()""/>
		|      </xsl:element>
		|
		|      <xsl:element name=""НаселПункт"">
		|        <xsl:value-of select=""tns:Structure/tns:Property[@name='НаселенныйПункт']/tns:Value/text()""/>
		|      </xsl:element>
		|
		|      <xsl:element name=""Улица"">
		|        <xsl:value-of select=""tns:Structure/tns:Property[@name='Улица']/tns:Value/text()""/>
		|      </xsl:element>
		|
		|      <xsl:variable name=""index"" select=""tns:Structure/tns:Property[@name='Индекс']/tns:Value/text()"" />
		|      <xsl:if test=""0!=count($index)"">
		|        <xsl:element name=""ДопАдрЭл"">
		|          <xsl:attribute name=""ТипАдрЭл"">" + УправлениеКонтактнойИнформациейКлиентСерверПовтИсп.КодСериализацииПочтовогоИндекса() + "</xsl:attribute>
		|          <xsl:attribute name=""Значение""><xsl:value-of select=""$index""/></xsl:attribute>
		|        </xsl:element>
		|      </xsl:if>
		|
		|      <xsl:call-template name=""add-elem-number"">
		|        <xsl:with-param name=""source"" select=""tns:Structure/tns:Property[@name='ТипДома']/tns:Value/text()"" />
		|        <xsl:with-param name=""defsrc"" select=""'Дом'"" />
		|        <xsl:with-param name=""value""  select=""tns:Structure/tns:Property[@name='Дом']/tns:Value/text()"" />
		|      </xsl:call-template>
		|
		|      <xsl:call-template name=""add-elem-number"">
		|        <xsl:with-param name=""source"" select=""tns:Structure/tns:Property[@name='ТипКорпуса']/tns:Value/text()"" />
		|        <xsl:with-param name=""defsrc"" select=""'Корпус'"" />
		|        <xsl:with-param name=""value""  select=""tns:Structure/tns:Property[@name='Корпус']/tns:Value/text()"" />
		|      </xsl:call-template>
		|
		|      <xsl:call-template name=""add-elem-number"">
		|        <xsl:with-param name=""source"" select=""tns:Structure/tns:Property[@name='ТипКвартиры']/tns:Value/text()"" />
		|        <xsl:with-param name=""defsrc"" select=""'Квартира'"" />
		|        <xsl:with-param name=""value""  select=""tns:Structure/tns:Property[@name='Квартира']/tns:Value/text()"" />
		|      </xsl:call-template>
		|    
		|    </xsl:element>
		|  </xsl:template>
		|
		|  <xsl:param name=""enum-codevalue"">
		|" + КодыДополнительныхАдресныхЭлементов.ПолучитьТекст() + "
		|  </xsl:param>
		|  <xsl:variable name=""enum-codevalue-nodes"" select=""exsl:node-set($enum-codevalue)"" />
		|
		|  <xsl:param name=""enum-regioncode"">
		|" + КодыРегионов.ПолучитьТекст() + "
		|  </xsl:param>
		|  <xsl:variable name=""enum-regioncode-nodes"" select=""exsl:node-set($enum-regioncode)"" />
		|  
		|  <xsl:template name=""add-elem-number"">
		|    <xsl:param name=""source"" />
		|    <xsl:param name=""defsrc"" />
		|    <xsl:param name=""value"" />
		|
		|    <xsl:if test=""0!=count($value)"">
		|
		|      <xsl:choose>
		|        <xsl:when test=""0!=count($source)"">
		|          <xsl:variable name=""type-code"" select=""$enum-codevalue-nodes/data:item[@data:title=$source]"" />
		|          <xsl:element name=""ДопАдрЭл"">
		|            <xsl:element name=""Номер"">
		|              <xsl:attribute name=""Тип""><xsl:value-of select=""$type-code"" /></xsl:attribute>
		|              <xsl:attribute name=""Значение""><xsl:value-of select=""$value""/></xsl:attribute>
		|            </xsl:element>
		|          </xsl:element>
		|
		|        </xsl:when>
		|        <xsl:otherwise>
		|          <xsl:variable name=""type-code"" select=""$enum-codevalue-nodes/data:item[@data:title=$defsrc]"" />
		|          <xsl:element name=""ДопАдрЭл"">
		|            <xsl:element name=""Номер"">
		|              <xsl:attribute name=""Тип""><xsl:value-of select=""$type-code"" /></xsl:attribute>
		|              <xsl:attribute name=""Значение""><xsl:value-of select=""$value""/></xsl:attribute>
		|            </xsl:element>
		|          </xsl:element>
		|
		|        </xsl:otherwise>
		|      </xsl:choose>
		|
		|    </xsl:if>
		|  
		|  </xsl:template>
		|  
		|</xsl:stylesheet>
		|");
	Возврат Преобразователь;
КонецФункции

// Преобразует сериализованную структуру в контактную информацию в виде XML.
//
// Возвращаемое значение:
//     ПреобразованиеXSL  - подготовленный объект.
//
Функция XSLT_СтруктураВАдресЭлектроннойПочты() Экспорт
	Возврат XSLT_СтруктураВСтроковыйСостав("ЭлектроннаяПочта");
КонецФункции

// Преобразует сериализованную структуру в контактную информацию в виде XML.
//
// Возвращаемое значение:
//     ПреобразованиеXSL  - подготовленный объект.
//
Функция XSLT_СтруктураВВебСтраницу() Экспорт
	Возврат XSLT_СтруктураВСтроковыйСостав("ВебСайт");
КонецФункции

// Преобразует сериализованную структуру в контактную информацию в виде XML.
//
Функция XSLT_СтруктураВТелефон() Экспорт
	Возврат XSLT_СтруктураВТелефонФакс("НомерТелефона");
КонецФункции

// Преобразует сериализованную структуру в контактную информацию в виде XML.
//
// Возвращаемое значение:
//     ПреобразованиеXSL  - подготовленный объект.
//
Функция XSLT_СтруктураВФакс() Экспорт
	Возврат XSLT_СтруктураВТелефонФакс("НомерФакса");
КонецФункции

// Преобразует сериализованную структуру в контактную информацию в виде XML.
//
// Возвращаемое значение:
//     ПреобразованиеXSL  - подготовленный объект.
//
Функция XSLT_СтруктураВДругое() Экспорт
	Возврат XSLT_СтруктураВСтроковыйСостав("Прочее");
КонецФункции

// Общее преобразование сериализованной структуры в контактную информацию в виде XML простого типа.
//
// Возвращаемое значение:
//     ПреобразованиеXSL  - подготовленный объект.
//
Функция XSLT_СтруктураВСтроковыйСостав(Знач ИмяXDTOТипа)
	Преобразователь = Новый ПреобразованиеXSL;
	Преобразователь.ЗагрузитьИзСтроки("
		|<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""
		|  xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""
		|  xmlns:tns=""http://v8.1c.ru/8.1/data/core""
		|  xmlns=""http://www.v8.1c.ru/ssl/contactinfo"" 
		|>
		|<xsl:output method=""xml"" omit-xml-declaration=""yes"" indent=""yes"" encoding=""utf-8""/>
		|
		|<xsl:template match=""/"">
		|  
		|  <xsl:element name=""КонтактнаяИнформация"">
		|  
		|  <xsl:attribute name=""Представление"">
		|    <xsl:value-of select=""tns:Structure/tns:Property[@name='Представление']/tns:Value/text()""/>
		|  </xsl:attribute> 
		|  <xsl:element name=""Комментарий"">
		|    <xsl:value-of select=""tns:Structure/tns:Property[@name='Комментарий']/tns:Value/text()""/>
		|  </xsl:element>
		|  
		|  <xsl:element name=""Состав"">
		|    <xsl:attribute name=""xsi:type"">" + ИмяXDTOТипа + "</xsl:attribute>
		|    <xsl:attribute name=""Значение"">
		|    <xsl:choose>
		|      <xsl:when test=""0=count(tns:Structure/tns:Property[@name='Значение'])"">
		|      <xsl:value-of select=""tns:Structure/tns:Property[@name='Представление']/tns:Value/text()""/>
		|      </xsl:when>
		|      <xsl:otherwise>
		|      <xsl:value-of select=""tns:Structure/tns:Property[@name='Значение']/tns:Value/text()""/>
		|      </xsl:otherwise>
		|    </xsl:choose>
		|    </xsl:attribute>
		|    
		|  </xsl:element>
		|  </xsl:element>
		|  
		|</xsl:template>
		|</xsl:stylesheet>
		|");
	Возврат Преобразователь;
КонецФункции

// Общее преобразование для телефона и факса.
//
// Возвращаемое значение:
//     ПреобразованиеXSL  - подготовленный объект.
//
Функция XSLT_СтруктураВТелефонФакс(Знач ИмяXDTOТипа) Экспорт
	Преобразователь = Новый ПреобразованиеXSL;
	Преобразователь.ЗагрузитьИзСтроки("
		|<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""
		|  xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""
		|  xmlns:tns=""http://v8.1c.ru/8.1/data/core""
		|  xmlns=""http://www.v8.1c.ru/ssl/contactinfo"" 
		|>
		|<xsl:output method=""xml"" omit-xml-declaration=""yes"" indent=""yes"" encoding=""utf-8""/>
		|  <xsl:template match=""/"">
		|
		|    <xsl:element name=""КонтактнаяИнформация"">
		|
		|      <xsl:attribute name=""Представление"">
		|        <xsl:value-of select=""tns:Structure/tns:Property[@name='Представление']/tns:Value/text()""/>
		|      </xsl:attribute> 
		|      <xsl:element name=""Комментарий"">
		|        <xsl:value-of select=""tns:Structure/tns:Property[@name='Комментарий']/tns:Value/text()""/>
		|      </xsl:element>
		|      <xsl:element name=""Состав"">
		|        <xsl:attribute name=""xsi:type"">" + ИмяXDTOТипа + "</xsl:attribute>
		|
		|        <xsl:attribute name=""КодСтраны"">
		|          <xsl:value-of select=""tns:Structure/tns:Property[@name='КодСтраны']/tns:Value/text()""/>
		|        </xsl:attribute> 
		|        <xsl:attribute name=""КодГорода"">
		|          <xsl:value-of select=""tns:Structure/tns:Property[@name='КодГорода']/tns:Value/text()""/>
		|        </xsl:attribute> 
		|        <xsl:attribute name=""Номер"">
		|          <xsl:value-of select=""tns:Structure/tns:Property[@name='НомерТелефона']/tns:Value/text()""/>
		|        </xsl:attribute> 
		|        <xsl:attribute name=""Добавочный"">
		|          <xsl:value-of select=""tns:Structure/tns:Property[@name='Добавочный']/tns:Value/text()""/>
		|        </xsl:attribute> 
		|
		|      </xsl:element>
		|    </xsl:element>
		|
		|  </xsl:template>
		|</xsl:stylesheet>
		|");
	Возврат Преобразователь;
КонецФункции

// Фрагмент XSL с процедурами для обработки строк.
//
// Возвращаемое значение:
//     Строка - фрагмент XML для использования в преобразовании.
//
Функция XSLT_ШаблоныСтроковыхФункций()
	Возврат "
		|<!-- string functions -->
		|
		|  <xsl:template name=""str-trim-left"">
		|    <xsl:param name=""str"" />
		|    <xsl:variable name=""head"" select=""substring($str, 1, 1)""/>
		|    <xsl:variable name=""tail"" select=""substring($str, 2)""/>
		|    <xsl:choose>
		|      <xsl:when test=""(string-length($str) > 0) and (string-length(normalize-space($head)) = 0)"">
		|        <xsl:call-template name=""str-trim-left"">
		|          <xsl:with-param name=""str"" select=""$tail""/>
		|        </xsl:call-template>
		|      </xsl:when>
		|      <xsl:otherwise>
		|        <xsl:value-of select=""$str""/>
		|      </xsl:otherwise>
		|    </xsl:choose>
		|  </xsl:template>
		|
		|  <xsl:template name=""str-trim-right"">
		|    <xsl:param name=""str"" />
		|    <xsl:variable name=""head"" select=""substring($str, 1, string-length($str) - 1)""/>
		|    <xsl:variable name=""tail"" select=""substring($str, string-length($str))""/>
		|    <xsl:choose>
		|      <xsl:when test=""(string-length($str) > 0) and (string-length(normalize-space($tail)) = 0)"">
		|        <xsl:call-template name=""str-trim-right"">
		|          <xsl:with-param name=""str"" select=""$head""/>
		|        </xsl:call-template>
		|      </xsl:when>
		|      <xsl:otherwise>
		|        <xsl:value-of select=""$str""/>
		|      </xsl:otherwise>
		|    </xsl:choose>
		|  </xsl:template>
		|
		|  <xsl:template name=""str-trim-all"">
		|    <xsl:param name=""str"" />
		|      <xsl:call-template name=""str-trim-right"">
		|        <xsl:with-param name=""str"">
		|          <xsl:call-template name=""str-trim-left"">
		|            <xsl:with-param name=""str"" select=""$str""/>
		|          </xsl:call-template>
		|      </xsl:with-param>
		|    </xsl:call-template>
		|  </xsl:template>
		|
		|  <xsl:template name=""str-replace-all"">
		|    <xsl:param name=""str"" />
		|    <xsl:param name=""search-for"" />
		|    <xsl:param name=""replace-by"" />
		|    <xsl:choose>
		|      <xsl:when test=""contains($str, $search-for)"">
		|        <xsl:value-of select=""substring-before($str, $search-for)"" />
		|        <xsl:value-of select=""$replace-by"" />
		|        <xsl:call-template name=""str-replace-all"">
		|          <xsl:with-param name=""str"" select=""substring-after($str, $search-for)"" />
		|          <xsl:with-param name=""search-for"" select=""$search-for"" />
		|          <xsl:with-param name=""replace-by"" select=""$replace-by"" />
		|        </xsl:call-template>
		|      </xsl:when>
		|      <xsl:otherwise>
		|        <xsl:value-of select=""$str"" />
		|      </xsl:otherwise>
		|    </xsl:choose>
		|  </xsl:template>
		|
		|  <xsl:param name=""alpha-low"" select=""'абвгдеёжзийклмнопрстуфхцчшщыъьэюяabcdefghijklmnopqrstuvwxyz'"" />
		|  <xsl:param name=""alpha-up""  select=""'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЫЪЬЭЮЯABCDEFGHIJKLMNOPQRSTUVWXYZ'"" />
		|
		|  <xsl:template name=""str-upper"">
		|    <xsl:param name=""str"" />
		|    <xsl:value-of select=""translate($str, $alpha-low, $alpha-up)""/>
		|  </xsl:template>
		|
		|  <xsl:template name=""str-lower"">
		|    <xsl:param name=""str"" />
		|    <xsl:value-of select=""translate($str, alpha-up, $alpha-low)"" />
		|  </xsl:template>
		|
		|<!-- /string functions -->
		|";
КонецФункции

// Определяет наличие подсистемы АдресныйКлассификатор и наличие записей о регионах в регистре сведений
// АдресныеОбъекты.
//
// Возвращаемое значение:
//  ФиксированноеСоответствие - с полями:
//   * КлассификаторДоступен   - Булево - классификатор доступен через веб-сервис.
//   * ИспользоватьЗагруженные - Булево - в программу загружен классификатор.
//
Функция СведенияОДоступностиАдресногоКлассификатора() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("КлассификаторДоступен",   Ложь);
	Результат.Вставить("ИспользоватьЗагруженные", Ложь);
	
	ЕстьКлассификатор = ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.АдресныйКлассификатор");
	Если Не ЕстьКлассификатор Тогда
		Возврат Результат;
	КонецЕсли;
	
	МодульАдресныйКлассификаторСлужебный = ОбщегоНазначения.ОбщийМодуль("АдресныйКлассификаторСлужебный");
	СведенияОДоступностиАдресныхСведений = МодульАдресныйКлассификаторСлужебный.СведенияОДоступностиАдресныхСведений();
	
	Возврат СведенияОДоступностиАдресныхСведений;
	
КонецФункции

// Возвращает значение перечисления тип вида контактной информации.
//
//  Параметры:
//    ВидИнформации - СправочникСсылка.ВидыКонтактнойИнформации, Структура - источник данных.
//
Функция ТипВидаКонтактнойИнформации(Знач ВидИнформации) Экспорт
	Результат = Неопределено;
	
	Тип = ТипЗнч(ВидИнформации);
	Если Тип = Тип("ПеречислениеСсылка.ТипыКонтактнойИнформации") Тогда
		Результат = ВидИнформации;
	ИначеЕсли Тип = Тип("СправочникСсылка.ВидыКонтактнойИнформации") Тогда
		Результат = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ВидИнформации, "Тип");
	ИначеЕсли ВидИнформации <> Неопределено Тогда
		Данные = Новый Структура("Тип");
		ЗаполнитьЗначенияСвойств(Данные, ВидИнформации);
		Результат = Данные.Тип;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Функция НаименованияВидовКонтактнойИнформации() Экспорт
	
	Результат = Новый Соответствие;
	Для каждого Язык Из Метаданные.Языки Цикл
		Наименования = Новый Соответствие;
		УправлениеКонтактнойИнформациейПереопределяемый.ПриПолученииНаименованийВидовКонтактнойИнформации(Наименования, Язык.КодЯзыка);
		Результат[Язык.КодЯзыка] = Наименования;
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

// Возвращает список предопределенных видов контактной информации.
//
// Возвращаемое значение:
//  ФиксированноеСоответствие - с полями:
//   * Ключ - Строка - имя предопределенного вида.
//   * Значение - СправочникСсылка.ВидыКонтактнойИнформации - ссылка на элемент справочника ВидыКонтактнойИнформации.
Функция ВидыКонтактнойИнформацииПоИмени() Экспорт
	
	Виды = Новый Соответствие;
	ПредопределенныеВиды = УправлениеКонтактнойИнформацией.ПредопределенныеВидыКонтактнойИнформации();
	
	Для каждого ПредопределенныеВид Из ПредопределенныеВиды Цикл
		Виды.Вставить(ПредопределенныеВид.Имя, ПредопределенныеВид.Ссылка);
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Виды);
	
КонецФункции

Функция КонтактнаяИнформацияОбъектаСодержитКолонкуДействуетС(ОбъектСсылка) Экспорт
	Возврат ОбъектСсылка.Метаданные().ТабличныеЧасти.КонтактнаяИнформация.Реквизиты.Найти("ДействуетС") <> Неопределено;
КонецФункции

#КонецОбласти
