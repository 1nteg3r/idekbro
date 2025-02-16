const express = require("express");
const axios = require("axios");

const app = express();

const PASTEBIN_API_KEY = "dec737f4cfa5817b78bb5e16e23eda1d"; // Replace with your Pastebin API key
const PASTEBIN_RAW_URL = "https://pastebin.com/raw/SwPcMyHy"; // Raw URL of your stored IP list
const PASTEBIN_POST_URL = "https://pastebin.com/api/api_post.php";
const PASTEBIN_LOGIN = "Unipex";
const PASTEBIN_PASSWORD = "$piderm@n15!061203";

let pastebinSessionKey = null; // Store session key

// Function to get IP from request
const getClientIP = (req) => {
    return req.headers["x-forwarded-for"] || req.connection.remoteAddress;
};

// Function to fetch existing IPs from Pastebin
async function fetchIPList() {
    try {
        const response = await axios.get(PASTEBIN_RAW_URL);
        return response.data.split("\n");
    } catch (error) {
        console.error("[ERROR] Failed to fetch IP list:", error);
        return [];
    }
}

// Function to log into Pastebin and get session key (needed to update pastes)
async function getPastebinSession() {
    if (pastebinSessionKey) return pastebinSessionKey; // Use cached session

    try {
        const response = await axios.post(PASTEBIN_POST_URL, null, {
            params: {
                api_dev_key: PASTEBIN_API_KEY,
                api_user_name: PASTEBIN_LOGIN,
                api_user_password: PASTEBIN_PASSWORD,
                api_option: "login",
            },
        });
        pastebinSessionKey = response.data;
        return response.data;
    } catch (error) {
        console.error("[ERROR] Failed to authenticate with Pastebin:", error);
        return null;
    }
}

// Function to update Pastebin with new IPs
async function updateIPList(newIP) {
    const existingIPs = await fetchIPList();
    if (existingIPs.includes(newIP)) {
        console.log(`[INFO] IP ${newIP} already registered.`);
        return;
    }

    existingIPs.push(newIP); // Add new IP

    const updatedIPList = existingIPs.join("\n");
    const sessionKey = await getPastebinSession();

    if (!sessionKey) {
        console.error("[ERROR] Cannot update Pastebin without session key.");
        return;
    }
A
    try {
        await axios.post(PASTEBIN_POST_URL, null, {
            params: {
                api_dev_key: PASTEBIN_API_KEY,
                api_user_key: sessionKey,
                api_paste_code: updatedIPList,
                api_paste_name: "Verified_IPs",
                api_paste_format: "text",
                api_paste_private: "1",
                api_option: "edit",
            },
        });
        console.log(`[SUCCESS] Added IP ${newIP} to Pastebin!`);
    } catch (error) {
        console.error("[ERROR] Failed to update Pastebin:", error);
    }
}

// Handle visits to the verification website
app.get("/verify", async (req, res) => {
    const userIP = getClientIP(req);
    console.log(`[INFO] Visitor IP detected: ${userIP}`);

    await updateIPList(userIP); // Register IP

    res.send(`<h1>IP ${userIP} has been registered!</h1>`);
});

// Start server
app.listen(3000, () => {
    console.log("Server running on port 3000...");
});
