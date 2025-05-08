library(dplyr)
library(ggplot2)
library(stringr)
library(lubridate)
library(scales)
library(wordcloud)
library(tm)
library(ggrepel)
library(tidyr)

filtered_games <- games2025 %>%
  filter(price > 0, !str_detect(genres, "Software|Video Production|Utilities|Design & Illustration|Education"))

top_positive_games <- filtered_games %>%
  mutate(is_indie = str_detect(genres, "Indie")) %>%
  arrange(desc(positive)) %>%
  head(30)

plot1 <- ggplot(top_positive_games, aes(x = reorder(name, positive), y = positive, fill = is_indie)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "En Çok Olumlu İnceleme Alan Top 30 Oyun",
    x = "Oyun",
    y = "Olumlu İnceleme Sayısı",
    fill = "Oyun Türü"
  ) +
  scale_fill_manual(
    values = c("TRUE" = "#FF6F61", "FALSE" = "#6B5B95"),
    labels = c("TRUE" = "Bağımsız", "FALSE" = "Yüksek Bütçeli")
  ) +
  scale_y_continuous(labels = label_number(scale = 1e-3, suffix = "K")) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold"),
    legend.title = element_text(face = "bold"),
    legend.text = element_text(face = "bold")
  )

games_by_year <- games2025 %>%
  filter(!is.na(release_date), str_detect(release_date, "^\\d{4}")) %>%
  mutate(
    year = as.integer(str_sub(release_date, 1, 4)),
    is_indie = str_detect(sapply(tags, paste, collapse = ","), regex("Indie", ignore_case = TRUE))
  ) %>%
  filter(year >= 2015 & year <= 2024) %>%
  group_by(year, is_indie) %>%
  summarise(count = n(), .groups = "drop")

plot2 <- ggplot(games_by_year, aes(x = factor(year), y = count, fill = is_indie)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(
    title = "Yıllara Göre Yayınlanan Bağımsız ve Yüksek Bütçeli Oyunlar",
    x = "Yıl",
    y = "Oyun Sayısı",
    fill = "Oyun Türü"
  ) +
  scale_fill_manual(values = c("TRUE" = "#FF6F61", "FALSE" = "#6B5B95"),
                    labels = c("TRUE" = "Bağımsız", "FALSE" = "Yüksek Bütçeli")) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold"),
    legend.title = element_text(face = "bold"),
    legend.text = element_text(face = "bold")
  )

current_year <- year(Sys.Date())
last_five_years <- current_year - 10

recent_indie_games <- games2025 %>%
  filter(str_detect(genres, "Indie"), !is.na(release_date)) %>%
  mutate(release_date = ymd(release_date)) %>%
  filter(year(release_date) >= last_five_years)

turkish_months <- c("Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara")

monthly_releases <- recent_indie_games %>%
  mutate(
    release_year = year(release_date),
    release_month = month(release_date),
    release_month = factor(release_month, levels = 1:12, labels = turkish_months)
  ) %>%
  group_by(release_year, release_month) %>%
  tally() %>%
  ungroup()

plot3 <- ggplot(monthly_releases, aes(x = release_month, y = factor(release_year), fill = n)) +
  geom_tile(color = "white", linewidth = 0.5) +
  scale_fill_gradient(low = "#F0F7FF", high = "#0057B7", breaks = pretty_breaks()) +
  labs(
    title = "Aylara ve Yıllara Göre Bağımsız Oyun Çıkışlarının Isı Haritası (Son 10 Yıl)",
    x = "Ay",
    y = "Yıl",
    fill = "Çıkış Sayısı"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5),
    axis.title = element_text(face = "bold", size = 12),
    axis.text = element_text(face = "bold", size = 10),
    axis.text.x = element_text(angle = 0),
    legend.title = element_text(face = "bold", size = 12),
    legend.text = element_text(face = "bold", size = 10),
    panel.grid = element_blank()
  ) +
  coord_fixed()

indie_games <- filtered_games %>%
  filter(str_detect(genres, "Indie"))

titles_text <- paste(indie_games$name, collapse = " ")

custom_stopwords <- c("sex", "porn", "hentai")

titles_corpus <- Corpus(VectorSource(titles_text)) %>%
  tm_map(content_transformer(tolower)) %>%
  tm_map(removePunctuation) %>%
  tm_map(removeNumbers) %>%
  tm_map(removeWords, c(stopwords("en"), custom_stopwords))

highlight_pal <- colorRampPalette(c("#FF6F61", "#6B5B95", "#88B04B", "#FFD700"))(8)

svg("plot4.svg", width = 8, height = 6, bg = "transparent")
par(mar = c(0,0,0,0))
wordcloud(
  words = titles_corpus,
  max.words = 200,
  random.order = FALSE,
  colors = highlight_pal
)
dev.off()

indie_games <- games2025 %>%
  filter(str_detect(genres, "Indie"))

indie_tags_raw <- indie_games %>%
  select(appid, tags, estimated_owners) %>%
  mutate(
    tags_clean = str_sub(tags, 2, -2),
    tag_pair   = str_split(tags_clean, ", ")
  ) %>%
  unnest(tag_pair) %>%
  separate(tag_pair, into = c("raw_tag", "frequency"), sep = ":", extra = "merge") %>%
  transmute(
    appid,
    tag        = str_trim(raw_tag) %>% str_replace_all("^['\"]|['\"]$", "") %>% str_replace("Indie", ""),
    estimated_owners = as.numeric(str_trim(frequency))
  )

indie_tags <- indie_tags_raw %>%
  filter(tag != "" & !is.na(tag)) %>%
  distinct(appid, tag, .keep_all = TRUE)

tag_summary <- indie_tags %>%
  group_by(tag) %>%
  summarize(
    total_owners = sum(estimated_owners, na.rm = TRUE),
    game_count = n(),
    .groups = "drop"
  )

tag_summary_filtered <- tag_summary %>%
  filter(total_owners > 20)

top_30_tags <- tag_summary_filtered %>%
  arrange(desc(total_owners)) %>%
  slice_head(n = 30)

plot6 <- ggplot(top_30_tags, aes(
  x     = game_count,
  y     = total_owners,
  label = tag
)) +
  geom_point(alpha = 0.7, color = "#FF6F61", size = 4) +
  geom_text_repel(max.overlaps = 30, box.padding = 0.5, min.segment.length = 1, size = 3, color = "black", fontface = "bold") +
  scale_x_continuous(labels = label_comma()) +
  scale_y_continuous(labels = label_comma()) +
  labs(
    title = "Ücretli Bağımsız Oyunlardaki En İyi 30 Etiket",
    subtitle = "Müşteri Sayısı Tahminidir",
    x     = "Etiketi Kullanan Bağımsız Oyun Sayısı",
    y     = "Tahmini Müşteri Sayısı",
    size  = "Oyun Sayısı"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold"),
    legend.title = element_text(face = "bold"),
    legend.text = element_text(face = "bold")
  )

ggsave("plot1.svg", plot = plot1, bg = "transparent")
ggsave("plot2.svg", plot = plot2, bg = "transparent")
ggsave("plot3.svg", plot = plot3, bg = "transparent")
ggsave("plot5.svg", plot = plot5, bg = "transparent")
ggsave("plot6.svg", plot = plot6, bg = "transparent")