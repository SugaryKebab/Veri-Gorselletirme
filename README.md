# Bağımsız Stüdyoların Steam Verilerinin R ile Görselleştirilmesi

Bu proje, bağımsız oyun stüdyolarının Steam platformundaki verilerini R programlama dili kullanılarak görselleştirmeyi amaçlamaktadır. Amaç, bu görselleştirmeler aracılığıyla bağımsız stüdyoların performanslarını, oyunlarının özelliklerini ve genel eğilimleri anlamaktır.

## Veri Seti

Veri görselleştirme sürecinde kullanılan veri seti, Kaggle platformunda bulunan "Steam Games Dataset"idir.

**Veri Seti Bağlantısı:** [https://www.kaggle.com/datasets/artermiloff/steam-games-dataset](https://www.kaggle.com/datasets/artermiloff/steam-games-dataset)

**Güncellik:** Veriler, 2025 Mart ayına kadar olan bilgileri içermektedir.

## Satış Rakamları ve Ciroların Tahmini

Veri setinde doğrudan satış rakamları ve cirolar bulunmamaktadır. Bu nedenle, bu değerler "İnceleme Çarpanı" (veya Boxleiter Oranı) yöntemi kullanılarak tahmin edilmiştir.

### İnceleme Çarpanı Yöntemi

İnceleme sayısını tahmini satış sayısına dönüştürmek için bir "inceleme çarpanı" kullanılır. Bu çarpan, bir oyunun aldığı her inceleme başına ortalama kaç adet sattığını temsil eder.

**Örnek:** Bir oyun 1.000 inceleme aldıysa ve kullanılan inceleme çarpanı 30 ise, tahmini satış sayısı şu şekilde hesaplanır:

Tahmini Satış Sayısı = İnceleme Sayısı * İnceleme Çarpanı
Tahmini Satış Sayısı = 1000 * 30 = 30.000 adet

### Çarpanların Doğruluğu Hakkında

Bu çarpanların nispeten doğru sonuçlar vermesinin temel nedeni, geniş Steam oyunları veri kümelerinin analizine dayanmasıdır. VG Insights gibi platformlar ve analistler, hem inceleme sayıları hem de (bazı durumlarda sızıntılar, geliştirici paylaşımları veya toplanmış veriler aracılığıyla) gerçek satış rakamları bilinen oyunların geçmiş verilerini inceleyerek farklı oyun kategorileri için ortalama satış-inceleme oranlarını belirleyebilmektedirler. Bu analizler, genelleştirilmiş ve kategorilere özel inceleme çarpanlarının oluşturulmasına olanak tanır.

**Kaynak:** [https://vginsights.com/insights/article/how-to-estimate-steam-video-game-sales](https://vginsights.com/insights/article/how-to-estimate-steam-video-game-sales)
## Projenin İçeriği ve Görselleştirmeler

Bu proje kapsamında aşağıdaki görselleştirmeler R kullanılarak oluşturulmuştur:

* **En Çok Olumlu İnceleme Alan Top 30 Oyun:** Bağımsız olup olmadıklarına göre renklendirilmiş çubuk grafik ile en fazla olumlu incelemeye sahip 30 oyunun gösterilmesi.
* **Yıllara Göre Yayınlanan Bağımsız ve Yüksek Bütçeli Oyunlar:** 2015-2024 yılları arasında yayınlanan bağımsız ve yüksek bütçeli oyun sayısının yığılmış çubuk grafik ile karşılaştırılması.
* **Aylara ve Yıllara Göre Bağımsız Oyun Çıkışlarının Isı Haritası (Son 10 Yıl):** Son 10 yılda bağımsız oyun çıkışlarının aylık ve yıllık dağılımının ısı haritası üzerinde gösterilmesi.
* **Bağımsız Oyun İsimlerindeki Kelime Bulutu:** Bağımsız oyunların isimlerinde en sık geçen kelimelerin görselleştirilmesi.
* **Ücretli Bağımsız Oyunlardaki En İyi 30 Etiket (Tahmini Müşteri Sayısı):** Ücretli bağımsız oyunlarda en sık kullanılan 30 etiketin ve bu etiketlere sahip oyunların tahmini müşteri sayılarının saçılım grafiği ile gösterilmesi.

## Kullanılan Araçlar

* **R Programlama Dili:** Veri analizi ve görselleştirme için temel araç.
* **R Kütüphaneleri:**
    * `dplyr`: Veri manipülasyonu için.
    * `ggplot2`: Etkileyici ve özelleştirilebilir grafikler oluşturmak için.
    * `stringr`: String (metin) işlemleri için.
    * `lubridate`: Tarih ve zaman verilerini işlemek için.
    * `scales`: Grafiklerde ölçekleri düzenlemek için.
    * `wordcloud`: Kelime bulutları oluşturmak için.
    * `tm`: Metin madenciliği işlemleri için.
    * `ggrepel`: Etiketlerin birbirine çakışmasını önlemek için.
    * `tidyr`: Veri çerçevelerini düzenlemek için.
