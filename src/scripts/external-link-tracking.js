document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll('a[href^="http"]').forEach(function (link) {
    link.addEventListener("click", function (event) {
      var url = link.getAttribute("href");
      gtag("event", "click", {
        event_category: "External Link",
        event_label: url,
        transport_type: "beacon",
        event_callback: function () {
          document.location = url;
        },
      });
      event.preventDefault();
    });
  });
});
